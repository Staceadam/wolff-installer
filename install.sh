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
check_and_install "fail2ban-client" "sudo apt install fail2ban -y"

# Check if ufw is installed
check_and_install "ufw" "sudo apt install ufw -y"

# Check if ripgrep is installed
check_and_install "rg" "sudo apt install ripgrep -y"

# Check if nginx is installed
check_and_install "nginx" "sudo apt install nginx -y"

# Check if prometheus is installed
check_and_install "prometheus" "sudo apt install prometheus -y"
alert info "opening up prometheus ports 9090 and 9100"
sudo ufw allow 9090
sudo ufw allow 9100

# Check if grafana is installed
check_and_install "dpkg -l | grep -q grafana" "
  sudo mkdir -p /etc/apt/keyrings/ &&
  wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null &&
  echo deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main | sudo tee -a /etc/apt/sources.list.d/grafana.list &&
  sudo apt install grafana -y
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

# Update netplan configuration file
netplan_file="/etc/netplan/01-netcfg.yaml"
netplan_static_file="/etc/netplan/static.yaml"

if [ -f "$netplan_static_file" ]; then
    alert success "Static configuration file found. All done."
    exit 1
fi

if [ ! -f "$netplan_file" ]; then
    alert warning "Netplan configuration file not found: $netplan_file. Exiting"
    exit 1
fi

# get the interface name
interface_name=$(ifconfig -lu | tr ' ' '\n' | while read -r interface; do
    if [[ "$(ifconfig "$interface" 2>/dev/null)" == *"status: active"* ]]; then
        if [[ "$(ifconfig "$interface" 2>/dev/null)" == *"ether"* ]]; then
            echo "$interface"
            break
        fi
    fi
done)

# Get IP address
ip_address=$(ip route get 1 | awk '{print $NF;exit}')

# Get gateway IP address
gateway_ip=$(ip route | grep default | awk '{print $3}')

# Print the captured information

alert info "Ethernet Interface: $interface_name"
alert info "IP Address: $ip_address. This is the current ip address assigned by the gateway."
alert info "Gateway IP: $gateway_ip"

# Backup the original file
alert info "Backing up $netplan_file configuration file."
sudo cp "$netplan_file" "$netplan_file.bak"

# Delete original file
sudo rm "$netplan_file" 

# Copy over base config file
sudo cp "./static.yaml" "$netplan_static_file"

# Update the YAML file with the current IP address
sed -i "s|<INTERFACE_NAME>|$interface_name|g" "$netplan_static_file" 
sed -i "s|<IP_ADDRESS>|$ip_address|g" "$netplan_static_file"
sed -i "s|<GATEWAY_IP>|$gateway_ip|g" config.yaml

alert success "Netplan configuration updated successfully."
alert success "current config is: "
sudo cat $netplan_static_file

alert success "Double check that the configuration is correct before applying these updates as they can disable ssh. You can run 'sudo netplan apply' to apply the updates."

duration=$SECONDS
minutes=$((duration / 60))
seconds=$((duration % 60))
alert success "Install script ran successfully at $minutes:$seconds"