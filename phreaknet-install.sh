#!/bin/bash

# Function to execute commands with or without sudo
run_command() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "WARNING: You are running as a non-root user. Will attempt to use sudo for elevation"
    sudo "$@"
  else
    echo "CAUTION: You are running as the root user, please be careful!"
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

echo "Detecting operating system..."
# Detect the operating system
OS=$(uname)
echo "Operating system detected: $OS"

# Define commands for Linux
if [ "$OS" = "Linux" ]; then
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
