# GitLab Group Repository Cloner

This repository contains scripts to clone all repositories from a GitLab group and its subgroups while maintaining the folder structure locally.

## Features

- 🔄 Recursively clones all repositories from a GitLab group and its subgroups
- 📁 Maintains the original folder structure locally
- 🔄 Updates existing repositories instead of re-cloning
- 🚫 Skips archived repositories
- 🛡️ Handles API pagination automatically
- 🎯 Avoids duplicate cloning of the same repository
- 📊 Provides detailed progress feedback

## Prerequisites

### For Python version
- Python 3.6+
- `requests` library
- `git` command available in PATH

### For Bash version
- `curl` command
- `jq` command (JSON processor)
- `git` command available in PATH

## Installation

### Python version
```bash
pip install -r requirements.txt
```

### Bash version
```bash
# Ubuntu/Debian
sudo apt-get install curl jq git

# macOS
brew install curl jq git

# Make script executable
chmod +x clone_gitlab_group.sh
```

## GitLab Access Token

You need a GitLab access token with `read_api` permissions:

1. Go to your GitLab instance → User Settings → Access Tokens
2. Create a new token with `read_api` scope
3. Copy the token (starts with `glpat-`)

## Usage

### Python version

```bash
python clone_gitlab_group.py --group-id <group_id> --token <access_token> [options]
```

**Options:**
- `--group-id`: GitLab group ID or path (required)
- `--token`: GitLab access token (required)
- `--base-url`: GitLab instance URL (default: https://gitlab.com)
- `--output-dir`: Output directory (default: ./gitlab-repositories)

**Examples:**
```bash
# Clone from gitlab.com
python clone_gitlab_group.py --group-id mygroup --token glpat-xxxxxxxxxxxx

# Clone from custom GitLab instance
python clone_gitlab_group.py --group-id mygroup --token glpat-xxxxxxxxxxxx --base-url https://gitlab.example.com

# Clone to specific directory
python clone_gitlab_group.py --group-id parent/subgroup --token glpat-xxxxxxxxxxxx --output-dir ./my-repos
```

### Bash version

```bash
./clone_gitlab_group.sh -g <group_id> -t <token> [options]
```

**Options:**
- `-g, --group-id`: GitLab group ID or path (required)
- `-t, --token`: GitLab access token (required)
- `-u, --url`: GitLab instance URL (default: https://gitlab.com)
- `-o, --output-dir`: Output directory (default: ./gitlab-repositories)
- `-h, --help`: Show help message

**Examples:**
```bash
# Clone from gitlab.com
./clone_gitlab_group.sh -g mygroup -t glpat-xxxxxxxxxxxx

# Clone from custom GitLab instance
./clone_gitlab_group.sh -g mygroup -t glpat-xxxxxxxxxxxx -u https://gitlab.example.com

# Clone to specific directory
./clone_gitlab_group.sh -g parent/subgroup -t glpat-xxxxxxxxxxxx -o ./my-repos
```

## How it works

1. **Group Discovery**: The script starts with the specified group and recursively discovers all subgroups
2. **Repository Enumeration**: For each group, it fetches all repositories (projects)
3. **Folder Structure**: Creates local folders that mirror the GitLab group structure
4. **Smart Cloning**: 
   - Clones new repositories
   - Updates existing repositories with `git pull`
   - Skips archived repositories
   - Avoids duplicate processing

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
./gitlab-repositories/
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

## Security Notes

- Store your GitLab token securely
- Use environment variables instead of command line arguments for tokens in production
- Consider using SSH keys for git operations

## Troubleshooting

### Common Issues

1. **Authentication Error**: Verify your token has `read_api` permissions
2. **Network Error**: Check your GitLab URL and network connectivity
3. **Permission Denied**: Ensure you have access to the group and its repositories
4. **Git Clone Fails**: Check if you have SSH keys set up for your GitLab instance

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
python clone_gitlab_group.py --group-id $GITLAB_GROUP_ID --token $GITLAB_TOKEN --base-url $GITLAB_URL --output-dir $OUTPUT_DIR
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License.
