#!/bin/bash
# test-setup.sh
# This script creates a minimal testing environment for dotFiles

# Make script exit on error
set -e

echo "Starting minimal test setup..."

# Create symlink to dotfiles (required for setup.sh to work)
ln -sf /home/testuser/dotfiles /home/testuser/.dotfiles

# Copy the scripts directory to the home folder
echo "Copying scripts directory..."
cp -R /home/testuser/dotfiles/scripts /home/testuser/scripts

# Create other required directories
mkdir -p /home/testuser/dev
mkdir -p /home/testuser/bin

# Create empty shell configuration files (setup.sh will populate them)
touch /home/testuser/.bash_profile
touch /home/testuser/.zshrc

# Show the resulting environment
echo "Created environment:"
ls -la /home/testuser

# Create a simplified README explaining how to test the setup
cat > /home/testuser/README_TESTING.md << 'EOF'
# Testing dotFiles Setup

This container has been prepared with the minimal environment needed to test the dotFiles setup.
The following folders have been set up:

- /home/testuser/dotfiles - The source dotFiles repository
- /home/testuser/.dotfiles - Symlink to the dotFiles repository
- /home/testuser/scripts - Scripts needed by the dotFiles setup
- /home/testuser/dev - Development folder

## Manual Testing

You can manually run the setup script with:

```bash
cd /home/testuser/dotfiles
./setup.sh
```

## Notes on Homebrew

The setup.sh script has been modified to automatically add Homebrew to your PATH
in the shell configuration files. After running setup.sh, you should be able to use
Homebrew commands without any additional configuration.

EOF

# Display next steps
echo "====================================="
echo "Minimal test environment created!"
echo "====================================="
echo "The container is now ready for testing."
echo "Connect to the container with: docker exec -it automated-test /bin/bash"
echo "Then you can run: cd /home/testuser/dotfiles && ./setup.sh"
echo "====================================="

# Keep container running for inspection
tail -f /dev/null