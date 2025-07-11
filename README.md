# Git Scripts Collection

A collection of useful Git automation scripts and tools to streamline your Git workflow. Each script is fully self-contained and can be used independently.

## 🚀 Available Scripts

### 📁 [GitLab Group Cloner](./gitlab-group-cloner/)
A powerful bash script to clone all repositories from a GitLab group and its subgroups while maintaining the folder structure locally.

**Features:**
- 🔄 Recursively clones all repositories from GitLab groups and subgroups
- 📁 Maintains original folder structure locally
- 🔄 Updates existing repositories instead of re-cloning
- 🚫 Skips archived repositories
- 🛡️ Handles API pagination automatically
- 🔐 Supports both SSH and HTTPS cloning
- 🎛️ Two modes: API Discovery and Manual Mode

**Quick Start:**
```bash
cd gitlab-group-cloner
./clone_gitlab_group.sh -g <group_id> -t <token>
```

### 🛡️ [Pre-Push Protection Hook](./pre-push-protection/)
A Git pre-push hook that prevents accidental pushes to the default branch by requiring explicit confirmation.

**Features:**
- 🛡️ Automatic default branch detection (main/master/etc.)
- 🎯 Smart caching to avoid repeated remote calls
- ⚠️ Clear warning messages with confirmation prompts
- 🌍 Locale-independent operation
- 🔄 Works with multiple remotes

**Quick Start:**
```bash
cd pre-push-protection
cp pre-push /path/to/your/repo/.git/hooks/
chmod +x /path/to/your/repo/.git/hooks/pre-push
```

## 🛠️ Installation

### Prerequisites
Most scripts require these common tools:
- `bash` shell
- `git` command
- `curl` command
- `jq` command (JSON processor)

### Ubuntu/Debian
```bash
sudo apt-get install curl jq git
```

### macOS
```bash
brew install curl jq git
```

### Make Scripts Executable
```bash
find . -name "*.sh" -type f -exec chmod +x {} \;
```

## 📋 Usage

Each script has its own directory with detailed documentation. Navigate to the specific script folder and read its README for detailed usage instructions.

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Add New Scripts**: Create a new folder for your script with:
   - The script file(s)
   - A detailed README.md
   - Any necessary configuration files

2. **Improve Existing Scripts**: 
   - Fix bugs
   - Add new features
   - Improve documentation

3. **Documentation**: Help improve READMEs and add examples

### Script Structure Guidelines

When adding a new script, please follow this structure:
```
script-name/
├── README.md           # Detailed documentation
├── script-name.sh      # Main script file (fully self-contained)
├── config/            # Configuration files (if needed)
└── examples/          # Usage examples (if applicable)
```

**Important**: Each script should be fully self-contained with all necessary functions and utilities included within the script file itself.

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-script`)
3. Commit your changes (`git commit -m 'Add amazing Git script'`)
4. Push to the branch (`git push origin feature/amazing-script`)
5. Open a Pull Request

## 📝 Script Ideas

Looking for inspiration? Here are some useful Git scripts that could be added:

- **Branch Cleanup**: Remove merged branches automatically
- **Commit Message Validator**: Ensure commit messages follow conventions
- **Repository Backup**: Backup repositories to multiple locations
- **Git Hooks Manager**: Install and manage Git hooks across projects
- **Pull Request Creator**: Automate PR creation with templates
- **Release Manager**: Automate version tagging and releases
- **Repository Statistics**: Generate reports on repository activity
- **Batch Operations**: Perform operations across multiple repositories
- **Git Flow Automation**: Automate Git Flow workflows
- **Submodule Manager**: Manage Git submodules efficiently

## 📖 Best Practices

When writing Git scripts:

1. **Self-Contained**: Each script should include all necessary functions and utilities
2. **Error Handling**: Always handle errors gracefully
3. **Documentation**: Include clear usage instructions and examples
4. **Configuration**: Make scripts configurable via command line arguments and/or config files
5. **Safety**: Include dry-run modes for destructive operations
6. **Compatibility**: Test on multiple platforms when possible
7. **Dependencies**: Clearly document all dependencies
8. **Security**: Handle credentials securely (use environment variables, tokens, etc.)

## 🐛 Issues and Support

If you encounter issues:

1. Check the specific script's README for troubleshooting
2. Search existing issues
3. Create a new issue with:
   - Script name and version
   - Operating system
   - Error messages
   - Steps to reproduce

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Acknowledgments

- Thanks to all contributors who help make Git workflows easier
- Inspired by the Git community's automation efforts
- Built with ❤️ for developers who love efficient workflows

---

**Happy Git scripting!** 🎉
