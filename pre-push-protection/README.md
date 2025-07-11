# Pre-Push Protection Hook

A Git pre-push hook that prevents accidental pushes to the default branch (main/master) by requiring explicit confirmation.

## 🛡️ Features

- **Default Branch Protection**: Detects and protects the default branch automatically
- **Smart Detection**: Automatically identifies whether your repository uses `main`, `master`, or another default branch
- **Caching**: Stores the default branch name to avoid repeated API calls
- **Confirmation Prompt**: Requires explicit "yes" confirmation before pushing to the default branch
- **Locale-Independent**: Works consistently across different system locales
- **Fallback Safety**: Defaults to protecting `main` if detection fails

## 📋 What It Does

When you attempt to push to your repository's default branch, the hook will:

1. **Detect the default branch** (main, master, etc.) from your remote
2. **Cache the result** in `.git/default_branch_cache` for future use
3. **Show a warning** when you're pushing to the default branch
4. **Require confirmation** by typing "yes" to proceed
5. **Cancel the push** if you don't confirm

## 🚀 Installation

### Quick Installation

```bash
# Clone or download the script
cd your-repository
cp /path/to/pre-push-protection/pre-push .git/hooks/
chmod +x .git/hooks/pre-push
```

### Manual Installation

1. **Copy the script** to your repository's hooks directory:
   ```bash
   cp pre-push /path/to/your/repo/.git/hooks/
   ```

2. **Make it executable**:
   ```bash
   chmod +x /path/to/your/repo/.git/hooks/pre-push
   ```

### Global Installation

To install for all new repositories:

```bash
# Set up a global hooks directory
git config --global init.templatedir '~/.git-templates'
mkdir -p ~/.git-templates/hooks

# Copy the hook
cp pre-push ~/.git-templates/hooks/
chmod +x ~/.git-templates/hooks/pre-push

# All new repositories will now have this hook
```

## 📖 Usage

Once installed, the hook works automatically. Here's what you'll see:

### Normal Branch Push (No Confirmation Required)
```bash
git push origin feature-branch
# Pushes normally without any prompts
```

### Default Branch Push (Confirmation Required)
```bash
git push origin main
⚠️  You are pushing to the default branch 'main'.
Are you sure? Type 'yes' to proceed: yes
# Push continues after confirmation
```

### Cancelled Push
```bash
git push origin main
⚠️  You are pushing to the default branch 'main'.
Are you sure? Type 'yes' to proceed: no
❌ Push to main cancelled.
# Push is cancelled
```

## 🔧 Configuration

The hook automatically detects your repository's default branch, but you can customize its behavior:

### Manual Default Branch Override

If you need to override the detected default branch:

```bash
# Set a custom default branch in the cache
echo "custom-main" > .git/default_branch_cache
```

### Disable for a Single Push

To temporarily bypass the hook for a single push:

```bash
git push origin main --no-verify
```

### Remove the Hook

To remove the protection:

```bash
rm .git/hooks/pre-push
```

## 🏗️ How It Works

1. **Remote Detection**: Uses `git remote show` to identify the default branch
2. **Caching**: Stores the result in `.git/default_branch_cache` to avoid repeated remote calls
3. **Branch Comparison**: Compares the target branch with the cached default branch
4. **User Confirmation**: Prompts for explicit confirmation when pushing to the default branch
5. **Fallback**: Uses "main" as default if detection fails

## 🛠️ Troubleshooting

### Common Issues

1. **Hook not running**: Ensure the file is executable (`chmod +x .git/hooks/pre-push`)
2. **Wrong default branch detected**: Delete `.git/default_branch_cache` to force re-detection
3. **Permission denied**: Make sure you have write permissions in the `.git` directory

### Debug Mode

To debug the hook, you can add debug output:

```bash
#!/bin/bash
set -x  # Add this line at the top for debug output
# ... rest of the script
```

### Manual Default Branch Detection

Test default branch detection manually:

```bash
# Test the detection command
LC_ALL=C git remote show origin | awk '/HEAD branch/ {print $NF}'
```

## 📝 Customization

### Modify the Confirmation Message

Edit the script to change the warning message:

```bash
echo "🚨 DANGER: You are pushing to the default branch '$default_branch'."
read -p "Type 'CONFIRM' to proceed: " confirmation
if [ "$confirmation" != "CONFIRM" ]; then
```

### Add Additional Protections

Extend the script to protect other branches:

```bash
# Add protection for release branches
if [[ "$branch_name" == release/* ]]; then
  echo "⚠️  You are pushing to a release branch."
  read -p "Are you sure? Type 'yes' to proceed: " confirmation
  if [ "$confirmation" != "yes" ]; then
    echo "❌ Push to release branch cancelled."
    exit 1
  fi
fi
```

### Integration with CI/CD

For automated environments, you might want to skip the hook:

```bash
# Skip in CI environments
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$GITLAB_CI" ]; then
  exit 0
fi
```

## 🔄 Multiple Remotes

The hook automatically uses the remote you're pushing to:

```bash
git push origin main    # Uses 'origin' remote
git push upstream main  # Uses 'upstream' remote
```

## 🌟 Best Practices

1. **Install globally** using the template directory for consistent protection
2. **Test the hook** after installation to ensure it works correctly
3. **Keep the cache file** in your `.gitignore` if you commit hook configurations
4. **Regular updates** - periodically check if the default branch has changed
5. **Team coordination** - ensure all team members have the same protection in place

## 📊 Related Scripts

This hook pairs well with other Git automation scripts:

- **Branch cleanup scripts** - Remove merged branches automatically
- **Commit message validators** - Ensure consistent commit messages
- **Release automation** - Automate version tagging and releases

## 🔐 Security Considerations

- The hook runs locally and doesn't send any data externally
- The cache file is stored in your local `.git` directory
- No sensitive information is stored or transmitted

## 📄 License

This script is part of the Git Scripts Collection and is licensed under the MIT License.

## 🤝 Contributing

To improve this hook:

1. Fork the repository
2. Make your changes
3. Test thoroughly with different repository configurations
4. Submit a pull request with clear description of improvements

---

**Stay safe and avoid accidental pushes to your default branch!** 🛡️
