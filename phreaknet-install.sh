#!/bin/bash

# Function to execute commands with or without sudo
run_command() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "NOTICE: You are running as a non-root user. Attempting to use sudo for: $*"
    sudo "$@"
  else
    echo "CAUTION: You are running as the root user. Executing: $*"
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

  # Navigate to /usr/local/src and download the script
  echo "Navigating to /usr/local/src..."
  run_command cd /usr/local/src

  echo "Downloading phreaknet.sh..."
  run_command wget https://raw.githubusercontent.com/InterLinked1/phreakscript/master/phreaknet.sh

  echo "Making phreaknet.sh executable..."
  run_command chmod +x phreaknet.sh

  echo "Running phreaknet.sh with 'make' argument..."
  run_command ./phreaknet.sh make

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

  # Navigate to /usr/local/src and download the script
  echo "Navigating to /usr/local/src..."
  run_command cd /usr/local/src

  echo "Downloading phreaknet.sh..."
  run_command wget https://raw.githubusercontent.com/InterLinked1/phreakscript/master/phreaknet.sh

  echo "Making phreaknet.sh executable..."
  run_command chmod +x phreaknet.sh

  echo "Running phreaknet.sh with 'make' argument..."
  run_command ./phreaknet.sh make

# If the OS is not recognized, print a message
else
  echo "Unsupported operating system: $OS"
  exit 1
fi

echo "Script completed successfully. Thank you for calling Phreaknet!"
