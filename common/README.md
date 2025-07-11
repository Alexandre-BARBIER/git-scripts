# Common Utilities

This directory contains shared utilities and helper functions that can be used across different Git scripts in this collection.

## 📁 Files

### `utils.sh`
A comprehensive collection of utility functions for bash scripts, including:

- **Logging Functions**: Colored output for info, success, warning, error, and debug messages
- **System Checks**: Verify required commands and dependencies
- **Git Utilities**: Check repositories, get branch info, verify clean state
- **User Interface**: Progress bars, confirmation prompts
- **File Operations**: Directory creation, path handling
- **Command Execution**: Dry-run support, command validation
- **Timer Functions**: Track script execution time
- **Configuration**: Load settings from files

## 🚀 Usage

To use these utilities in your scripts, source the utils file:

```bash
#!/bin/bash

# Source the common utilities
source "$(dirname "$0")/../common/utils.sh"

# Now you can use the functions
log_info "Starting script execution"
check_requirements "git" "curl" "jq"
start_timer

# Your script logic here

log_success "Script completed in $(end_timer)"
```

## 🔧 Available Functions

### Logging Functions
```bash
log_info "Information message"
log_success "Success message"
log_warning "Warning message"
log_error "Error message"
log_debug "Debug message"  # Only shows if DEBUG=true
```

### System Checks
```bash
# Check if command exists
if command_exists "git"; then
    log_info "Git is available"
fi

# Check multiple requirements
check_requirements "git" "curl" "jq"
```

### User Interaction
```bash
# Confirm action (default: no)
if confirm "Do you want to continue?"; then
    log_info "User confirmed"
fi

# Confirm with default yes
if confirm "Proceed?" "y"; then
    log_info "User confirmed (or used default)"
fi
```

### Git Utilities
```bash
# Check if directory is a Git repository
if is_git_repo "/path/to/repo"; then
    log_info "This is a Git repository"
fi

# Get current branch
current_branch=$(get_current_branch)
log_info "Current branch: $current_branch"

# Check if working directory is clean
if is_git_clean; then
    log_info "Working directory is clean"
fi

# Get remote URL
remote_url=$(get_git_remote_url)
log_info "Remote URL: $remote_url"
```

### Progress Display
```bash
total_items=100
for i in $(seq 1 $total_items); do
    # Your processing logic here
    progress_bar $i $total_items
    sleep 0.1
done
echo  # New line after progress bar
```

### Command Execution
```bash
# Execute with dry-run support
execute "git pull origin main"

# Set dry-run mode
DRY_RUN=true
execute "rm -rf dangerous_directory"  # Will only print what would be executed
```

### Timer Functions
```bash
start_timer
# Your long-running operation
duration=$(end_timer)
log_info "Operation completed in $duration"
```

### Directory Management
```bash
ensure_directory "/path/to/create"
```

### Configuration Loading
```bash
load_config "/path/to/config.sh"
```

## 🎛️ Environment Variables

The utilities respect several environment variables:

- `DEBUG`: Set to `true` to enable debug logging
- `QUIET`: Set to `true` to suppress non-error output
- `DRY_RUN`: Set to `true` to enable dry-run mode

## 🔧 Signal Handling

The utilities include signal handling setup:

```bash
setup_signals  # Sets up cleanup on EXIT, INT, and TERM signals
```

## 📊 Example Script Template

Here's a template for creating new scripts using these utilities:

```bash
#!/bin/bash

# Exit on error
set -e

# Source common utilities
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/../common/utils.sh"

# Set up signal handlers
setup_signals

# Script configuration
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="1.0.0"

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Description of what this script does.

Options:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output
  -q, --quiet     Suppress non-error output
  --dry-run       Show what would be done without executing

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME --dry-run
  $SCRIPT_NAME --verbose

EOF
}

main() {
    # Parse command line arguments
    parse_args "$@"
    
    # Check requirements
    check_requirements "git"
    
    # Start timer
    start_timer
    
    log_info "Starting $SCRIPT_NAME v$SCRIPT_VERSION"
    
    # Your script logic here
    
    log_success "Script completed in $(end_timer)"
}

# Run main function
main "$@"
```

## 🤝 Contributing

When adding new utility functions:

1. Keep functions focused and reusable
2. Include proper error handling
3. Add documentation comments
4. Follow the existing naming conventions
5. Test functions across different environments

## 📝 Function Reference

For a complete list of available functions and their parameters, see the comments in `utils.sh`.
