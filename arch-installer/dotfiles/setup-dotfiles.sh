#!/bin/bash

# Execution validation (don't run as sudo)
if [[ "$EUID" -eq 0 ]]; then
    echo -e "Don't run this script as root or with sudo."
    echo "Run it from your normal user so the files are copied to your home correctly."
    exit 1
fi

# Variables
CONFIG_DIR="$HOME/.config"
BIN_DIR="$HOME/.local/bin"
REPO_DIR="$(pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%s)"

echo "Installing dotfiles..."

# Path validation
if [[ ! -d "$REPO_DIR/config" || ! -d "$REPO_DIR/scripts" ]]; then
    echo "Please run the script from the repository root"
    exit 1
fi

# Ask for backup
read -p "Do you want to backup your current files? (y/n): " make_backup

# Validate input
make_backup=$(echo "$make_backup" | tr '[:upper:]' '[:lower:]')

# Condition
if [[ "$make_backup" == "y" ]]; then
    BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%s)"
    echo "Creating backup in $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$CONFIG_DIR" "$BACKUP_DIR/config"
    cp -r "$BIN_DIR" "$BACKUP_DIR/bin"
    echo "Backup created successfully ✅"
fi

# Create directories if they don't exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# Copy configuration files
echo "Copying configurations..."
cp -r "$REPO_DIR/config/." "$CONFIG_DIR"

# Copy scripts
echo "Copying scripts..."
cp -r "$REPO_DIR/scripts/." "$BIN_DIR"
chmod +x "$BIN_DIR"/* # Grant execution permissions

# Output
echo "Dotfiles installed correctly ✅"
