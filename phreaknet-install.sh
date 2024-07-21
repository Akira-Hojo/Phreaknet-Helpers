#!/bin/bash

# Function to execute commands with or without sudo
run_command() {
  if [ "$USE_SUDO" = true ]; then
    sudo "$@"
  else
    "$@"
  fi

  # Check the status of the command
  if [ $? -ne 0 ]; then
    echo "ERROR: Command failed: $*" >&2
    exit 1
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if running as root or not
if [ "$(id -u)" -ne 0 ]; then
  echo "WARNING: You are running as a non-root user. Will attempt to use sudo for elevation."
  USE_SUDO=true
else
  echo "CAUTION: You are running as the root user, please be careful!"
  USE_SUDO=false
fi

# Detect the operating system
OS=$(uname)
echo "Operating system detected: $OS"

if [ "$OS" = "Linux" ]; then
  # Check if the distribution is Debian or Ubuntu
  if [ -f /etc/debian_version ]; then
    if command_exists lsb_release; then
      DISTRO=$(lsb_release -is)
    else
      DISTRO="Debian/Ubuntu"
    fi
    echo "Distribution detected: $DISTRO"

    echo "Checking for wget..."
    # Check if wget is installed, if not install it
    if ! command_exists wget; then
      echo "wget not found, installing..."
      run_command apt-get update
      run_command apt-get install -y wget
    else
      echo "wget is already installed."
    fi

    # Download the script to /usr/local/src
    echo "Downloading phreaknet.sh to /usr/local/src..."
    run_command wget -O /usr/local/src/phreaknet.sh https://docs.phreaknet.org/script/phreaknet.sh

    echo "Making phreaknet.sh executable..."
    run_command chmod +x /usr/local/src/phreaknet.sh

    echo "Running phreaknet.sh with 'make' argument..."
    run_command /usr/local/src/phreaknet.sh make
  else
    echo "Unsupported Linux distribution. This script only supports Debian or Ubuntu."
    exit 1
  fi

# Define commands for FreeBSD
elif [ "$OS" = "FreeBSD" ]; then
  echo "Checking for wget..."
  # Check if wget is installed, if not install it
  if ! command_exists wget; then
    echo "wget not found, installing..."
    run_command pkg update
    run_command pkg install -y wget
  else
    echo "wget is already installed."
  fi

  # Download the script to /usr/local/src
  echo "Downloading phreaknet.sh to /usr/local/src..."
  run_command wget -O /usr/local/src/phreaknet.sh https://docs.phreaknet.org/script/phreaknet.sh

  echo "Making phreaknet.sh executable..."
  run_command chmod +x /usr/local/src/phreaknet.sh

  echo "Running phreaknet.sh with 'make' argument..."
  run_command /usr/local/src/phreaknet.sh make

# If the OS is not recognized, print a message
else
  echo "Unsupported operating system: $OS"
  exit 1
fi

echo "Script completed successfully."
