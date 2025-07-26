#!/bin/bash
# Setup root user password and default user configuration for AASMI OS

set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Setting root user password..."
# WARNING: This sets a simple root password. For production systems,
# consider disabling root login or using a much stronger, randomized password.
echo "root:AASMI" | chpasswd
echo "Root password set to 'AASMI'."

echo "Creating default user 'aasmi' with password 'AASMI'..."

# Create user 'aasmi' if not exists, create home directory, add to sudo group, set bash as default shell
if ! id -u aasmi >/dev/null 2>&1; then
    useradd -m -G sudo -s /bin/bash aasmi
    echo "User 'aasmi' created."
else
    echo "User 'aasmi' already exists. Skipping user creation."
fi

# Set password for 'aasmi'
echo "aasmi:AASMI" | chpasswd
echo "Password for user 'aasmi' set to 'AASMI'."
echo "IMPORTANT: These default passwords ('AASMI') are for the live ISO. Please change them immediately after installation for security reasons!"

# Force password change for 'aasmi' on first login
echo "Forcing password change for user 'aasmi' on first login..."
chage -d 0 aasmi # Forces password change on next login

echo "User setup completed."