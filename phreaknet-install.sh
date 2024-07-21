#!/bin/bash

# Colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print messages in green
print_success() {
  echo -e "${GREEN}$1${NC}"
}

# Function to print warnings in yellow
print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

# Function to print errors in red
print_error() {
  echo -e "${RED}$1${NC}"
}

# Function to execute commands with or without sudo
run_command() {
  if [ "$USE_SUDO" = true ]; then
    sudo "$@"
  else
    "$@"
  fi

  # Check the status of the command
  if [ $? -ne 0 ]; then
    print_error "ERROR: Command failed: $*"
    exit 1
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check if phreaknet is already installed
check_phreaknet_installed() {
  if [ -f /usr/local/sbin/phreaknet ]; then
    print_warning "phreaknet is already installed at /usr/local/sbin/phreaknet."
    read -p "Would you like to remove it? (y/N): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      run_command rm /usr/local/sbin/phreaknet
      if [ $? -ne 0 ]; then
        print_error "Failed to remove /usr/local/sbin/phreaknet"
        exit 1
      fi
      print_success "Removed /usr/local/sbin/phreaknet successfully."
    else
      print_warning "Please remove /usr/local/sbin/phreaknet manually and re-run the script."
      exit 1
    fi
  fi
}

# Main script execution starts here

# Check if running as root or not
if [ "$(id -u)" -ne 0 ]; then
  print_warning "WARNING: You are running as a non-root user. Will attempt to use sudo for elevation."
  USE_SUDO=true
else
  print_warning "CAUTION: You are running as the root user, please be careful!"
  USE_SUDO=false
fi

# Detect the operating system
OS=$(uname)
print_success "Operating system detected: $OS"

# Check for phreaknet before proceeding
check_phreaknet_installed

if [ "$OS" = "Linux" ]; then
  # Check if the distribution is Debian or Ubuntu
  if [ -f /etc/debian_version ]; then
    if command_exists lsb_release; then
      DISTRO=$(lsb_release -is)
    else
      DISTRO="Debian/Ubuntu"
    fi
    print_success "Distribution detected: $DISTRO"

    print_warning "Checking for wget..."
    # Check if wget is installed, if not install it
    if ! command_exists wget; then
      print_warning "wget not found, installing..."
      run_command apt-get update
      run_command apt-get install -y wget
    else
      print_success "wget is already installed."
    fi

    # Download the script to /usr/local/src
    print_warning "Downloading phreaknet.sh to /usr/local/src..."
    run_command wget -O /usr/local/src/phreaknet.sh https://docs.phreaknet.org/script/phreaknet.sh

    print_warning "Making phreaknet.sh executable..."
    run_command chmod +x /usr/local/src/phreaknet.sh

    print_warning "Running phreaknet.sh with 'make' argument..."
    run_command /usr/local/src/phreaknet.sh make
  else
    print_error "Unsupported Linux distribution. This script only supports Debian or Ubuntu."
    exit 1
  fi

# Define commands for FreeBSD
elif [ "$OS" = "FreeBSD" ]; then
  print_warning "Checking for wget..."
  # Check if wget is installed, if not install it
  if ! command_exists wget; then
    print_warning "wget not found, installing..."
    run_command pkg update
    run_command pkg install -y wget
  else
    print_success "wget is already installed."
  fi

  # Download the script to /usr/local/src
  print_warning "Downloading phreaknet.sh to /usr/local/src..."
  run_command wget -O /usr/local/src/phreaknet.sh https://docs.phreaknet.org/script/phreaknet.sh

  print_warning "Making phreaknet.sh executable..."
  run_command chmod +x /usr/local/src/phreaknet.sh

  print_warning "Running phreaknet.sh with 'make' argument..."
  run_command /usr/local/src/phreaknet.sh make

# If the OS is not recognized, print a message
else
  print_error "Unsupported operating system: $OS"
  exit 1
fi

print_success "Script completed successfully."