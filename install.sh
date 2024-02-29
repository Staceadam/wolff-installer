#!/usr/bin/env bash

SECONDS=0

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

color_red='\033[0;31m'
color_green='\033[0;32m'
color_blue='\033[0;34m'
color_reset='\033[0m'

function alert() {
  local type="$1"
  local message="$2"
  
  if [[ "$type" == "warning" ]]; then
    echo -e "${color_red}${message}${color_reset}"
  elif [[ "$type" == "success" ]]; then
    echo -e "${color_green}${message}${color_reset}"
  elif [[ "$type" == "info" ]]; then
    echo -e "${color_blue}${message}${color_reset}"
  else
    echo -e "[ERROR] Invalid type specified."
  fi
}

function check_and_install() {
  local command_name="$1"
  local install_command="$2"
  local not_installed_message="$command_name is not installed, installing now..."
  local installed_message="$command_name has been installed."

  alert info "Checking if $command_name is installed..."

  if ! command_exists "$command_name"; then
    alert warning "$not_installed_message"
    eval "$install_command"
    alert success "$installed_message"
  else
    alert success "$command_name is already installed."
  fi
}

alert info "Checking for system updates."
sudo apt update 
sudo apt upgrade

# Check if vim is installed
check_and_install "vim" "sudo apt install vim -y"

# Check if Zsh and oh-my-zsh is installed
check_and_install "zsh" "sudo apt install zsh -y; sudo sh -c '$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)'"

# Check if htop is installed
check_and_install "htop" "sudo apt install htop -y"

# Check if git is installed
check_and_install "git" "sudo apt install git -y"

# Check if fail2ban is installed
check_and_install "fail2ban" "sudo apt install fail2ban -y"

# Check if ufw is installed
check_and_install "ufw" "sudo apt install ufw -y"

# Check if ripgrep is installed
check_and_install "rg" "sudo apt install ripgrep -y"

# Check if nginx is installed
check_and_install "nginx" "sudo apt install ripgrep -y"

# Check if prometheus is installed
check_and_install "prometheus" "sudo apt install prometheus -y"
alert info "opening up prometheus ports 9090 and 9100"
sudo ufw allow 9090
sudo ufw allow 9100

# Check if grafana is installed
check_and_install "grafana" "
  sudo mkdir -p /etc/apt/keyrings/ &&
  wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null &&
  echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list &&
  sudo apt update && sudo apt install grafana 
"
alert info "opening up grafana port 3000"
sudo ufw allow 3000

# Check if wireguard is installed
check_and_install "wg" "sudo apt install wireguard -y"

# Update packages
alert info "Attempting to update packages."
sudo apt update

alert info "Attempting to setup static ip and VPN"
# TODO: this needs to place and use the chicago conf file and set it up with an alias


alert info "Attempting to setup network."
alert info "Setting up static ip address."
bash ./static_ip.sh

duration=$SECONDS
minutes=$((duration / 60))
seconds=$((duration % 60))
alert success "Install script ran successfully at $minutes:$seconds"