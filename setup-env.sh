#!/bin/bash

# Function to display loading message
function loading() {
    echo -n "Loading..."
    while true; do
        echo -n "."
        sleep 1
    done
}

# Function to display success message
function success() {
    echo "Success"
}

# Function to display error message
function error() {
    echo "Error: $1"
}

# Step 1: Add Docker's official GPG key
echo -n "Adding Docker's official GPG key... "
loading &
LOADING_PID=$!

sudo apt-get update > /dev/null
sudo apt-get install -y ca-certificates curl > /dev/null
sudo install -m 0755 -d /etc/apt/keyrings > /dev/null
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc > /dev/null
kill $LOADING_PID && success || error "Failed to add GPG key"

# Step 2: Add the repository to Apt sources
echo -n "Adding repository to Apt sources... "
loading &
LOADING_PID=$!

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
kill $LOADING_PID && success || error "Failed to add repository to Apt sources"

# Step 3: Update Apt
echo -n "Updating Apt... "
loading &
LOADING_PID=$!

sudo apt-get update > /dev/null
kill $LOADING_PID && success || error "Failed to update Apt"

# Step 4: Install Docker
echo -n "Installing Docker... "
loading &
LOADING_PID=$!

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null
kill $LOADING_PID && success || error "Failed to install Docker"

# Step 5: Verify Docker installation
echo -n "Verifying Docker installation... "
loading &
LOADING_PID=$!

docker --version > /dev/null
kill $LOADING_PID && success || error "Failed to verify Docker installation"

# Step 6: Post-installation steps
echo -n "Running post-installation steps... "
loading &
LOADING_PID=$!

sudo groupadd docker > /dev/null
sudo usermod -aG docker $USER > /dev/null
kill $LOADING_PID && success || error "Failed to run post-installation steps"

# Prompt for reboot
read -p "Reboot is required to run Docker without sudo. Do you want to reboot to apply the changes? (y/n): " REBOOT_OPTION
if [[ $REBOOT_OPTION == "y" ]]; then
    sudo reboot
elif [[ $REBOOT_OPTION == "n" ]]; then
    echo "You chose not to reboot. Docker may require sudo to run."
else
    echo "Invalid option. Docker may require sudo to run."
fi
