#!/usr/bin/env bash

# Prompt for the username
read -p 'Enter the username: ' username

# Validate the username input
if ! [[ "$username" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid username. Only alphanumeric characters and underscores are allowed." 1>&2
    exit 1
fi

# Check if the username exists
if ! getent passwd "$username" > /dev/null 2>&1; then
    echo "User $username does not exist"
    exit 1
fi

# Prompt for confirmation
read -p "Are you sure you want to add user $username to the sudoers file? [y/N]: " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "Operation aborted by the user."
    exit 0
fi

# Use visudo to add the user to the sudoers file
echo "Adding user $username to the sudoers file..."
echo "$username    ALL=(ALL:ALL) ALL" | sudo EDITOR='tee -a' visudo > /dev/null

# Check if the line was added successfully
if sudo grep -q "$username" /etc/sudoers; then
    echo "User $username added to the sudoers file successfully"
else
    echo "Failed to add user $username to the sudoers file"
fi
