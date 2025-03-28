#!/bin/bash

# Import the logger
source lib/shared/logger.sh

# Function for checking if a package is installed
isInstalled() {
    local package="$1"

    # Check if the package is installed.
    if yay -Q "$package" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to install a package
installPackage() {
    local package="$1"

    # Install the package using yay.
    if ! isInstalled $package; then
        log "Info" "Installing $package..."
        yay -S --noconfirm --needed "$package"
        if [ $? -eq 0 ]; then
            log "Success" "$package installed successfully."
        else
            log "Error" "Failed to install $package."
        fi
    else
        log "Info" "Package $package is already installed."
    fi
}

# Function to install packages in groups
installPackages() {
    local package_group_name=$1
    local packages=("${!2}")

    # Install the packages in groups
    log "Info" "Installing $package_group_name packages..."
    for package in "${packages[@]}"; do
        installPackage "$package"
    done
    log "Success" "$package_group_name packages installation complete."
}

# Function to backup existing files or directories
backupFiles() {
    local source_dir=$1
    local backup_dir=$2
    local items=("${!3}")

    for item in "${items[@]}"; do
        if [ -e "$source_dir/$item" ]; then
            mkdir -p "$backup_dir"
            if [ -e "$backup_dir/$item" ]; then
                # If the item already exists in the backup directory, remove it first
                rm -rf "$backup_dir/$item"
                log "Info" "Removed existing $backup_dir/$item to avoid conflicts."
            fi
            mv "$source_dir/$item" "$backup_dir/"
            log "Info" "Backed up $source_dir/$item to $backup_dir/"
        else
            log "Warning" "$source_dir/$item does not exist. Skipping backup."
        fi
    done
}

# Function to copy new files or directories
copyFiles() {
    local source_dir=$1
    local target_dir=$2
    local items=("${!3}")

    for item in "${items[@]}"; do
        if [ -e "$source_dir/$item" ]; then
            cp -r "$source_dir/$item" "$target_dir/"
            log "Info" "Copied $source_dir/$item to $target_dir/"
        else
            log "Warning" "Source file or directory $source_dir/$item does not exist."
        fi
    done
}

# Function to restore files or directories from backup
restoreFiles() {
    local backup_dir=$1
    local target_dir=$2
    local items=("${!3}")

    for item in "${items[@]}"; do
        if [ -e "$backup_dir/$item" ]; then
            # Remove the existing item in the target directory
            rm -rf "$target_dir/$item"
            # Restore the item from the backup
            mv "$backup_dir/$item" "$target_dir/"
            log "Info" "Restored $backup_dir/$item to $target_dir/"
        else
            log "Warning" "$backup_dir/$item does not exist. Skipping restore."
        fi
    done
}
