# GitLab Group Repository Cloner

A bash script to clone all repositories from a GitLab group and its subgroups while maintaining the folder structure locally.

## Features

- 🔄 Recursively clones all repositories from a GitLab group and its subgroups
- 📁 Maintains the original folder structure locally
- 🔄 Updates existing repositories instead of re-cloning
- 🚫 Skips archived repositories
- 🛡️ Handles API pagination automatically
- 🎯 Avoids duplicate cloning of the same repository
- 📊 Provides detailed progress feedback
- 🔐 Supports both SSH and HTTPS cloning
- 🎛️ Two modes: API Discovery and Manual Mode

## Prerequisites

- `bash` shell
- `curl` command
- `jq` command (JSON processor)
- `git` command available in PATH

## Installation

```bash
# Ubuntu/Debian
sudo apt-get install curl jq git

# macOS
brew install curl jq git

# Make script executable
chmod +x clone_gitlab_group.sh
```

## GitLab Access Token

For API Discovery mode, you need a GitLab access token with `read_api` permissions:

1. Go to your GitLab instance → User Settings → Access Tokens
2. Create a new token with `read_api` scope
3. Copy the token (starts with `glpat-`)

**Note**: Manual mode can work without a token when using SSH cloning.

## Usage

The script supports two modes:

### 1. API Discovery Mode (Default)

Automatically discovers all repositories using the GitLab API:

```bash
./clone_gitlab_group.sh -g <group_id> -t <token> [options]
```

### 2. Manual Mode

Clone specific repositories without API discovery:

```bash
./clone_gitlab_group.sh -g <group_id> --manual-mode [options]
```

### Options

- `-g, --group-id`: GitLab group ID or path (required)
- `-t, --token`: GitLab access token (required for API mode, optional for manual mode)
- `-u, --url`: GitLab instance URL (default: https://gitlab.com)
- `-o, --output-dir`: Output directory (default: current directory)
- `--https`: Use HTTPS for git operations instead of SSH
- `--manual-mode`: Skip API discovery, manually specify repositories
- `-h, --help`: Show help message

### Examples

```bash
# API Discovery mode - clone all repositories
./clone_gitlab_group.sh -g mygroup -t glpat-xxxxxxxxxxxx

# API Discovery mode with custom GitLab instance
./clone_gitlab_group.sh -g mygroup -t glpat-xxxxxxxxxxxx -u https://gitlab.example.com -o ./repos

# Manual mode with SSH (no token needed)
./clone_gitlab_group.sh -g mygroup --manual-mode

# Manual mode with HTTPS
./clone_gitlab_group.sh -g mygroup --manual-mode --https -t glpat-xxxxxxxxxxxx
```

## How it works

### API Discovery Mode
1. **API Connection**: Tests connection to GitLab API with provided token
2. **Group Discovery**: Recursively discovers all subgroups starting from the specified group
3. **Repository Enumeration**: For each group, fetches all repositories (projects) via API
4. **Folder Structure**: Creates local folders that mirror the GitLab group structure
5. **Smart Cloning**: 
   - Clones new repositories
   - Updates existing repositories with `git pull`
   - Skips archived repositories
   - Avoids duplicate processing

### Manual Mode
1. **User Input**: Prompts user to enter repository paths manually
2. **Repository Cloning**: Clones each specified repository without API discovery
3. **Flexible Authentication**: Works with SSH keys (no token needed) or HTTPS with token

## Example Output Structure

If you have a GitLab group structure like:
```
myorg/
├── backend/
│   ├── api-service (repository)
│   └── auth-service (repository)
├── frontend/
│   ├── web-app (repository)
│   └── mobile-app (repository)
└── infrastructure/
    └── terraform (repository)
```

The script will create:
```
./output-directory/
└── myorg/
    ├── backend/
    │   ├── api-service/
    │   └── auth-service/
    ├── frontend/
    │   ├── web-app/
    │   └── mobile-app/
    └── infrastructure/
        └── terraform/
```

## Authentication Methods

### SSH (Default)
- Uses SSH keys for authentication
- No token required for git operations
- Requires SSH key setup with your GitLab instance

### HTTPS
- Uses HTTPS for git operations
- May require token for authentication
- Specify with `--https` flag

## Security Notes

- Store your GitLab token securely
- Use environment variables instead of command line arguments for tokens in production
- SSH keys are recommended for secure, passwordless authentication
- Ensure SSH agent is running with your key loaded

## Troubleshooting

### Common Issues

1. **Authentication Error**: 
   - Verify your token has `read_api` permissions
   - For SSH, ensure SSH keys are set up and SSH agent is running
2. **Network Error**: Check your GitLab URL and network connectivity
3. **Permission Denied**: Ensure you have access to the group and its repositories
4. **Git Clone Fails**: 
   - For SSH: Check if SSH keys are configured for your GitLab instance
   - For HTTPS: Verify token permissions
5. **jq not found**: Install jq with `sudo apt-get install jq` or `brew install jq`
6. **curl not found**: Install curl with your system package manager

### Environment Variables

You can set these environment variables instead of command line arguments:

```bash
export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
export GITLAB_URL="https://gitlab.example.com"
export GITLAB_GROUP_ID="mygroup"
export OUTPUT_DIR="./repositories"
```

Then run:
```bash
./clone_gitlab_group.sh -g "$GITLAB_GROUP_ID" -t "$GITLAB_TOKEN" -u "$GITLAB_URL" -o "$OUTPUT_DIR"
```

### SSH Key Setup

For SSH authentication (recommended):

1. Generate SSH key: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Add key to SSH agent: `ssh-add ~/.ssh/id_ed25519`
3. Add public key to GitLab: Copy `~/.ssh/id_ed25519.pub` to GitLab → Settings → SSH Keys
4. Test connection: `ssh -T git@gitlab.com`

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License.
