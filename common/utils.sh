#!/bin/bash

# Common utilities for Git scripts
# Source this file in your scripts: source "$(dirname "$0")/../common/utils.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required commands
check_requirements() {
    local requirements=("$@")
    local missing=()
    
    for cmd in "${requirements[@]}"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        log_info "Please install them using your package manager:"
        log_info "  Ubuntu/Debian: sudo apt-get install ${missing[*]}"
        log_info "  macOS: brew install ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Confirm action with user
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    
    if [[ "$default" == "y" ]]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1
    else
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

# Check if directory is a Git repository
is_git_repo() {
    local dir="${1:-.}"
    git -C "$dir" rev-parse --git-dir >/dev/null 2>&1
}

# Get Git remote URL
get_git_remote_url() {
    local dir="${1:-.}"
    local remote="${2:-origin}"
    
    if is_git_repo "$dir"; then
        git -C "$dir" remote get-url "$remote" 2>/dev/null
    else
        return 1
    fi
}

# Get current Git branch
get_current_branch() {
    local dir="${1:-.}"
    
    if is_git_repo "$dir"; then
        git -C "$dir" branch --show-current 2>/dev/null
    else
        return 1
    fi
}

# Check if Git working directory is clean
is_git_clean() {
    local dir="${1:-.}"
    
    if is_git_repo "$dir"; then
        [[ -z $(git -C "$dir" status --porcelain 2>/dev/null) ]]
    else
        return 1
    fi
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\rProgress: ["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"
}

# Validate URL format
is_valid_url() {
    local url="$1"
    [[ "$url" =~ ^https?:// ]] || [[ "$url" =~ ^git@ ]]
}

# Create directory if it doesn't exist
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            log_error "Failed to create directory: $dir"
            return 1
        }
    fi
}

# Cleanup function for trap
cleanup() {
    local exit_code=$?
    log_debug "Cleaning up..."
    # Add cleanup logic here
    exit $exit_code
}

# Set up signal handlers
setup_signals() {
    trap cleanup EXIT
    trap 'log_error "Script interrupted"; exit 130' INT
    trap 'log_error "Script terminated"; exit 143' TERM
}

# Parse command line arguments helper
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                DEBUG=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                # Handle positional arguments in your script
                break
                ;;
        esac
    done
}

# Execute command with dry-run support
execute() {
    local cmd="$*"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY RUN] Would execute: $cmd"
        return 0
    else
        log_debug "Executing: $cmd"
        eval "$cmd"
    fi
}

# Timer functions
start_timer() {
    TIMER_START=$(date +%s)
}

end_timer() {
    local start_time=${TIMER_START:-$(date +%s)}
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $duration -gt 60 ]]; then
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        echo "${minutes}m ${seconds}s"
    else
        echo "${duration}s"
    fi
}

# Version comparison
version_compare() {
    local version1="$1"
    local version2="$2"
    
    if [[ "$version1" == "$version2" ]]; then
        return 0
    fi
    
    local IFS=.
    local i ver1=($version1) ver2=($version2)
    
    for ((i=0; i<${#ver1[@]} || i<${#ver2[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if [[ -z ${ver1[i]} ]]; then
            ver1[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

# Get script directory
get_script_dir() {
    local script_path
    if [[ -L "$0" ]]; then
        script_path="$(readlink "$0")"
    else
        script_path="$0"
    fi
    dirname "$(cd "$(dirname "$script_path")" && pwd)"
}

# Load configuration from file
load_config() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        log_debug "Loading configuration from: $config_file"
        # shellcheck source=/dev/null
        source "$config_file"
    else
        log_debug "Configuration file not found: $config_file"
    fi
}

# Export functions for use in other scripts
export -f log_info log_success log_warning log_error log_debug
export -f command_exists check_requirements confirm
export -f is_git_repo get_git_remote_url get_current_branch is_git_clean
export -f progress_bar is_valid_url ensure_directory
export -f cleanup setup_signals parse_args execute
export -f start_timer end_timer version_compare
export -f get_script_dir load_config
