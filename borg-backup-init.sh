#!/bin/bash

# Show debugging output
#set -x

# ----------------------------------------------------------------------------
#           Initialize Borg Backup Repository and Daily Backups
# ----------------------------------------------------------------------------
#
# The Github project of this script:
#   https://github.com/eike-welk/borg-backup-scripts

# Configure error handler.
trap 'printf "\n\"borg-backup-init.sh\" was interrupted.\n"; exit 2' INT TERM

repo_dir="$PWD"
config_dir='/etc/borg-backup-test'
bin_dir='/usr/local/bin'

# Test: We need root permissions for nearly everything in this script.
if (( $(id -u) != 0 )); then
   echo "Error: This script needs to be run as root."
   exit 1
fi

# create the configuration directory, if it does not exist.
mkdir -p "$config_dir"

# Create secrets file if no configuration exists. -----------------------------
# The secrets file contains the repository name and password.
secrets_path="${config_dir}/repo-secrets.sh"
if [ ! -f "$secrets_path" ]; then
    echo "No repository configuration found."
    echo "This script will create a Borg repository in the current working directory."

    # Ask repository name
    read -e -p "Repository name: " repo_name
    borg_repo_path="${repo_dir}/${repo_name}"
    # Ask repository password
    read -e -p "Repository password: " repo_passphrase

    # Create secrets file
    echo "Creating repository configuration file:"
    echo "    $secrets_path"
    cat > "$secrets_path" << EOF
# The location of the backup repository.
BORG_REPO="$borg_repo_path"
# The repository's passphrase:
BORG_PASSPHRASE="$repo_passphrase"
EOF

else
    echo "Repository configuration already exists:"
    echo "    $secrets_path"
    echo "Edit / rename / delete this file if you want to use a different"
    echo "repository name or password."
fi
echo

# Create Rsync configuration file, if none exists. ---------------------------
rsync_config_path="${config_dir}/rsync-config.sh"
if [ ! -f "$rsync_config_path" ]; then
    echo "No rsync configuration found."
    echo "Enter the path of the cloned repository. (Can be left empty.)"

    # Ask for rsync locations
    read -e -p "Cloned repository: " rsync_target_dir_1

    # Create rsync configuration file
    echo "Creating \"rsync\" configuration file:"
    echo "    $rsync_config_path"
    cat > "$rsync_config_path" << EOF
# Directories where the original Borg repository should be copied to.
BORG_RSYNC_TARGET_DIR_1='${rsync_target_dir_1}'
BORG_RSYNC_TARGET_DIR_2=''
BORG_RSYNC_TARGET_DIR_3=''
BORG_RSYNC_TARGET_DIR_4=''
EOF

else
    echo "\"rsync\" configuration already exists:"
    echo "    $rsync_config_path"
    echo "Edit / rename / delete this file if you want to use a different"
    echo "\"rsync\" configuration."
fi
echo

# Write README.rst ------------------------------------------------------------
if [ ! -f "$repo_dir/README.rst" ]; then
    echo "Creating README.rst"
    cp "$bin_dir/borg-backup-readme.rst" "$repo_dir/README.rst"
else
    echo "README.rst already exists."
fi
echo

# Create restoration mount point. ---------------------------------------------
echo "Creating mount point (\"mnt/\") for restoring files, if necessary."
mkdir -p "${repo_dir}/mnt"

# TODO: Initialize repository. ----------------------------------------
# Set the repository location and passphrase.
source "$secrets_path"
export BORG_REPO
export BORG_PASSPHRASE
#     borg init --encryption=repokey /backup/borg-backup/lixie-backup-1.borg

# TODO: Start timer

