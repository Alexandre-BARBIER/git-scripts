#!/bin/bash

# GitLab Group Repository Cloner (Bash version)
# This is a simpler bash version that uses curl and jq

set -e

# Default values
GITLAB_URL="https://gitlab.com"
OUTPUT_DIR="."
GROUP_ID=""
TOKEN=""
USE_HTTPS=false
MANUAL_MODE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 -g <group_id> [-t <token>] [-u <gitlab_url>] [-o <output_dir>] [--https] [--manual-mode]"
    echo ""
    echo "Options:"
    echo "  -g, --group-id     GitLab group ID or path (required)"
    echo "  -t, --token        GitLab access token for API access (optional for manual mode)"
    echo "  -u, --url          GitLab instance URL (default: https://gitlab.com)"
    echo "  -o, --output-dir   Output directory (default: current directory)"
    echo "  --https            Use HTTPS for git operations instead of SSH (default: SSH)"
    echo "  --manual-mode      Skip API discovery, manually clone known repositories"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Modes:"
    echo "  1. API Discovery (default): Uses GitLab API to discover all repositories"
    echo "     - Requires: GitLab access token (-t)"
    echo "     - Discovers all repositories automatically"
    echo ""
    echo "  2. Manual Mode (--manual-mode): Clone repositories without API discovery"
    echo "     - Token optional (only for HTTPS cloning if required)"
    echo "     - You specify repository names/paths manually"
    echo ""
    echo "Note: This script uses SSH by default for git operations. Make sure you have:"
    echo "  - SSH key configured for your GitLab instance"
    echo "  - SSH agent running with your key loaded"
    echo ""
    echo "Examples:"
    echo "  # API Discovery mode"
    echo "  $0 -g mygroup -t glpat-xxxxxxxxxxxx"
    echo "  $0 -g parent/subgroup -t glpat-xxxxxxxxxxxx -u https://gitlab.example.com -o ./repos"
    echo ""
    echo "  # Manual mode (no token needed for SSH)"
    echo "  $0 -g mygroup --manual-mode"
    echo "  $0 -g mygroup --manual-mode --https -t glpat-xxxxxxxxxxxx  # HTTPS with token"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--group-id)
            GROUP_ID="$2"
            shift 2
            ;;
        -t|--token)
            TOKEN="$2"
            shift 2
            ;;
        -u|--url)
            GITLAB_URL="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --https)
            USE_HTTPS=true
            shift
            ;;
        --manual-mode)
            MANUAL_MODE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$GROUP_ID" ]]; then
    echo -e "${RED}Error: Group ID is required${NC}"
    usage
    exit 1
fi

# Validate token requirement based on mode
if [[ "$MANUAL_MODE" == "false" && -z "$TOKEN" ]]; then
    echo -e "${RED}Error: Token is required for API discovery mode${NC}"
    echo -e "${YELLOW}Use --manual-mode if you want to clone without API discovery${NC}"
    usage
    exit 1
fi

# Validate token requirement for HTTPS in manual mode
if [[ "$MANUAL_MODE" == "true" && "$USE_HTTPS" == "true" && -z "$TOKEN" ]]; then
    echo -e "${YELLOW}Warning: HTTPS cloning in manual mode may require authentication${NC}"
    echo -e "${YELLOW}Consider providing a token with -t or use SSH instead${NC}"
fi

# Check dependencies
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required but not installed${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}"
    echo "Install with: sudo apt-get install jq (Ubuntu/Debian) or brew install jq (macOS)"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is required but not installed${NC}"
    exit 1
fi

# Remove trailing slash from URL
GITLAB_URL="${GITLAB_URL%/}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Array to track processed repositories
declare -A processed_repos

# Function to make API calls
api_call() {
    local endpoint="$1"
    local page="${2:-1}"
    local per_page="${3:-100}"
    
    if [[ -z "$TOKEN" ]]; then
        echo -e "${RED}Error: Token required for API calls${NC}"
        return 1
    fi
    
    curl -s -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        "$GITLAB_URL/api/v4$endpoint?page=$page&per_page=$per_page"
}

# Function to get all pages of an API endpoint
get_all_pages() {
    local endpoint="$1"
    local all_results="[]"
    local page=1
    
    while true; do
        local result=$(api_call "$endpoint" "$page")
        
        # Check if result is empty array or null
        if [[ "$result" == "[]" || "$result" == "null" ]]; then
            break
        fi
        
        # Check for API errors
        if echo "$result" | jq -e '.message' &> /dev/null; then
            echo -e "${RED}API Error: $(echo "$result" | jq -r '.message')${NC}"
            return 1
        fi
        
        # Merge results
        all_results=$(echo "$all_results" "$result" | jq -s 'add')
        
        # Check if we got less than per_page results (last page)
        local count=$(echo "$result" | jq 'length')
        if [[ "$count" -lt 100 ]]; then
            break
        fi
        
        ((page++))
    done
    
    echo "$all_results"
}

# Function to clone a repository
clone_repository() {
    local repo_name="$1"
    local repo_ssh_url="$2"
    local repo_https_url="$3"
    local target_dir="$4"
    local repo_id="$5"
    
    # Choose URL based on user preference
    local repo_url
    if [[ "$USE_HTTPS" == "true" ]]; then
        repo_url="$repo_https_url"
    else
        repo_url="$repo_ssh_url"
    fi
    
    # Check if already processed
    if [[ -n "${processed_repos[$repo_id]}" ]]; then
        echo -e "  ${YELLOW}Skipping $repo_name (already processed)${NC}"
        return 0
    fi
    
    echo -e "  ${GREEN}Cloning $repo_name...${NC}"
    
    local clone_path="$target_dir/$repo_name"
    
    # If directory exists, check if it's a valid git repo
    if [[ -d "$clone_path" ]]; then
        if [[ -d "$clone_path/.git" ]]; then
            echo -e "    ${YELLOW}Repository $repo_name already exists, pulling latest changes...${NC}"
            if (cd "$clone_path" && git pull); then
                echo -e "    ${GREEN}Successfully pulled $repo_name${NC}"
                processed_repos[$repo_id]=1
                return 0
            else
                echo -e "    ${RED}Warning: Failed to pull $repo_name${NC}"
                return 1
            fi
        else
            echo -e "    ${RED}Directory $clone_path exists but is not a git repository${NC}"
            return 1
        fi
    fi
    
    # Clone the repository
    if git clone "$repo_url" "$clone_path"; then
        echo -e "    ${GREEN}Successfully cloned $repo_name${NC}"
        processed_repos[$repo_id]=1
        return 0
    else
        echo -e "    ${RED}Error cloning $repo_name${NC}"
        return 1
    fi
}

# Function to manually clone a repository (without API)
manual_clone_repository() {
    local repo_path="$1"
    local target_dir="$2"
    
    # Extract repository name from path
    local repo_name=$(basename "$repo_path")
    
    # Build URLs
    local gitlab_host=$(echo "$GITLAB_URL" | sed -e 's|^https\?://||' -e 's|/.*$||')
    local repo_ssh_url="git@$gitlab_host:$repo_path.git"
    local repo_https_url="$GITLAB_URL/$repo_path.git"
    
    # Choose URL based on user preference
    local repo_url
    if [[ "$USE_HTTPS" == "true" ]]; then
        repo_url="$repo_https_url"
    else
        repo_url="$repo_ssh_url"
    fi
    
    echo -e "  ${GREEN}Cloning $repo_name...${NC}"
    
    local clone_path="$target_dir/$repo_name"
    
    # If directory exists, check if it's a valid git repo
    if [[ -d "$clone_path" ]]; then
        if [[ -d "$clone_path/.git" ]]; then
            echo -e "    ${YELLOW}Repository $repo_name already exists, pulling latest changes...${NC}"
            if (cd "$clone_path" && git pull); then
                echo -e "    ${GREEN}Successfully pulled $repo_name${NC}"
                return 0
            else
                echo -e "    ${RED}Warning: Failed to pull $repo_name${NC}"
                return 1
            fi
        else
            echo -e "    ${RED}Directory $clone_path exists but is not a git repository${NC}"
            return 1
        fi
    fi
    
    # Clone the repository
    if git clone "$repo_url" "$clone_path"; then
        echo -e "    ${GREEN}Successfully cloned $repo_name${NC}"
        return 0
    else
        echo -e "    ${RED}Error cloning $repo_name${NC}"
        return 1
    fi
}

# Function for manual mode - prompt user for repositories
manual_mode() {
    echo -e "${GREEN}Manual Mode: Clone repositories without API discovery${NC}"
    echo -e "${YELLOW}You'll need to specify repository paths manually${NC}"
    echo ""
    echo "Enter repository paths (one per line, relative to GitLab group):"
    echo "Examples:"
    echo "  myproject"
    echo "  subgroup/another-project"
    echo "  deep/nested/project"
    echo ""
    echo "Press Enter on an empty line to finish:"
    
    local repos=()
    while true; do
        read -p "Repository path: " repo_path
        if [[ -z "$repo_path" ]]; then
            break
        fi
        repos+=("$repo_path")
    done
    
    if [[ ${#repos[@]} -eq 0 ]]; then
        echo -e "${RED}No repositories specified${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Will clone ${#repos[@]} repositories${NC}"
    echo "=================================================="
    
    # Create group directory
    local group_dir="$OUTPUT_DIR"
    mkdir -p "$group_dir"
    
    # Clone each repository
    for repo_path in "${repos[@]}"; do
        # Handle nested paths by creating subdirectories
        local repo_name=$(basename "$repo_path")
        local repo_subdir=$(dirname "$repo_path")
        
        if [[ "$repo_subdir" != "." ]]; then
            local full_target_dir="$group_dir/$repo_subdir"
            mkdir -p "$full_target_dir"
            manual_clone_repository "$GROUP_ID/$repo_path" "$full_target_dir"
        else
            manual_clone_repository "$GROUP_ID/$repo_path" "$group_dir"
        fi
    done
}

# Function to process a group recursively
process_group() {
    local group_id="$1"
    local current_path="$2"
    local level="${3:-0}"
    
    local indent=""
    for ((i=0; i<level; i++)); do
        indent="  $indent"
    done
    
    # Get group information
    local group_info=$(api_call "/groups/$group_id")
    
    if echo "$group_info" | jq -e '.message' &> /dev/null; then
        echo -e "${RED}${indent}Error fetching group $group_id: $(echo "$group_info" | jq -r '.message')${NC}"
        return 1
    fi
    
    local group_name=$(echo "$group_info" | jq -r '.name')
    local group_path=$(echo "$group_info" | jq -r '.path')
    
    echo -e "${indent}${GREEN}Processing group: $group_name${NC}"
    
    # Create directory for this group
    local group_dir="$current_path/$group_path"
    mkdir -p "$group_dir"
    
    # Get and clone all projects in this group
    echo -e "${indent}${YELLOW}Fetching projects...${NC}"
    local projects=$(get_all_pages "/groups/$group_id/projects")
    
    if [[ "$projects" != "[]" ]]; then
        local project_count=$(echo "$projects" | jq 'length')
        echo -e "${indent}${GREEN}Found $project_count projects in $group_name${NC}"
        
        # Process each project
        echo "$projects" | jq -c '.[]' | while read -r project; do
            local repo_name=$(echo "$project" | jq -r '.name')
            local repo_ssh_url=$(echo "$project" | jq -r '.ssh_url_to_repo')
            local repo_https_url=$(echo "$project" | jq -r '.http_url_to_repo')
            local repo_id=$(echo "$project" | jq -r '.id')
            local archived=$(echo "$project" | jq -r '.archived')
            
            # Skip archived projects
            if [[ "$archived" == "true" ]]; then
                echo -e "  ${YELLOW}Skipping $repo_name (archived)${NC}"
                continue
            fi
            
            clone_repository "$repo_name" "$repo_ssh_url" "$repo_https_url" "$group_dir" "$repo_id"
        done
    fi
    
    # Get and process all subgroups
    echo -e "${indent}${YELLOW}Fetching subgroups...${NC}"
    local subgroups=$(get_all_pages "/groups/$group_id/subgroups")
    
    if [[ "$subgroups" != "[]" ]]; then
        local subgroup_count=$(echo "$subgroups" | jq 'length')
        echo -e "${indent}${GREEN}Found $subgroup_count subgroups in $group_name${NC}"
        
        # Process each subgroup
        echo "$subgroups" | jq -c '.[]' | while read -r subgroup; do
            local subgroup_id=$(echo "$subgroup" | jq -r '.id')
            process_group "$subgroup_id" "$group_dir" $((level + 1))
        done
    fi
}

# Main execution
main() {
    echo -e "${GREEN}Starting GitLab group cloner${NC}"
    echo -e "${GREEN}Group: $GROUP_ID${NC}"
    echo -e "${GREEN}Output directory: $OUTPUT_DIR${NC}"
    echo -e "${GREEN}GitLab URL: $GITLAB_URL${NC}"
    echo -e "${GREEN}Clone method: $(if [[ "$USE_HTTPS" == "true" ]]; then echo "HTTPS"; else echo "SSH"; fi)${NC}"
    echo -e "${GREEN}Mode: $(if [[ "$MANUAL_MODE" == "true" ]]; then echo "Manual"; else echo "API Discovery"; fi)${NC}"
    echo "=================================================="
    
    if [[ "$MANUAL_MODE" == "true" ]]; then
        # Manual mode - user specifies repositories
        manual_mode
    else
        # API discovery mode - discover repositories via API
        echo -e "${YELLOW}Testing API connection...${NC}"
        local test_result=$(api_call "/user")
        if echo "$test_result" | jq -e '.message' &> /dev/null; then
            echo -e "${RED}Error: Cannot connect to GitLab API${NC}"
            echo -e "${RED}$(echo "$test_result" | jq -r '.message')${NC}"
            exit 1
        fi
        
        local username=$(echo "$test_result" | jq -r '.username')
        echo -e "${GREEN}Connected as: $username${NC}"
        
        # Start processing
        if process_group "$GROUP_ID" "$OUTPUT_DIR"; then
            echo "=================================================="
            echo -e "${GREEN}✅ Cloning completed successfully!${NC}"
            echo -e "${GREEN}All repositories have been cloned to: $OUTPUT_DIR${NC}"
        else
            echo -e "${RED}❌ Error during cloning${NC}"
            exit 1
        fi
    fi
}

# Run main function
main
