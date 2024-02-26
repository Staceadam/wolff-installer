#!/usr/bin/env bash

# run apt update
# run apt upgrade

# [X] set a static ip address for the machine
# [X] install wireguard
#     [] config wireguard to have optional config for fastest surfshark vpn
# [X] check and install vim
# [X] install zsh and oh-my-zsh
# [X] install ripgrep 
# [X] install htop
# [X] install git
# [X] install fail2ban - this automatically bans anything trying to continually log into the system
# [X] check and install ufw

alert() {
    # RED='\033[0;31m'
    # GREEN='\033[0;32m'
    # YELLOW='\033[0;33m'

    local type="$1"
    local text="$2"
    local NC='\033[0m' # No Color
    local color='\033[0;33m' # No Color

    if [ "$type" == "success" ]; then
        color='\033[0;32m'
    elif [ "$type" == "warning" ]; then
        color='\033[0;31m'
    elif [ "$type" == "init" ]; then
        color='!!!!!!!!!!!!!! '
    else 
        color='\033[0m'
    fi
    
    echo "${color}${text}${NC}"
}

# Check if Vim is installed
alert 'init' "Vim"
if ! command -v vim &> /dev/null
then
    alert 'warning' "Vim is not installed. Installing..."
    # Update package index
    sudo apt update
    # Install Vim
    sudo apt install vim -y
    alert 'success' "Vim has been installed."
else
    alert 'success' "Vim is already installed."
fi

# Check if Zsh is installed
alert 'init' "Zsh and oh-my-zsh"
if ! command -v zsh &> /dev/null
then
    alert 'warning' "Zsh is not installed."
    sudo apt install zsh -y
    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    alert 'success' "Zsh and oh-myzsh have been installed."
else
    alert 'success' "Zsh is installed."
fi

# Check if htop is installed
alert 'init' "htop - process viewer"
if ! command -v htop &> /dev/null
then
    alert 'warning' "htop is not installed. Installing..."
    # Update package index
    sudo apt update
    # Install htop
    sudo apt install htop -y
    alert 'success' "htop has been installed."
else
    alert 'succes' "htop is already installed."
fi

# Check if git is installed
alert 'init' "git - source control"
if ! command -v git &> /dev/null
then
    alert 'warning' "git is not installed. Installing..."
    # Update package index
    sudo apt update
    # Install git
    sudo apt install git -y
    alert 'success' "git has been installed."
else
    alert 'success' "git is already installed."
fi

# Check if fail2ban is installed
alert 'init' "fail2ban - ssh auto banner"
if ! command -v fail2ban &> /dev/null
then
    alert 'warning' "fail2ban is not installed. Installing..."
    # Update package index
    sudo apt update
    # Install fail2ban
    sudo apt install fail2ban -y
    alert 'success' "fail2ban installed successfully."
else
    alert 'success' "fail2ban is already installed."
fi

# Check if UFW is installed
alert 'init' "ufw - firewall"
if ! command -v ufw &> /dev/null
then
    alert 'warning' "UFW is not installed. Installing..."
    # Update package index
    sudo apt update
    # Install UFW
    sudo apt install ufw -y
    alert 'success' "UFW installed successfully."
else
    alert 'success' "UFW is already installed."
fi

# Check if WireGuard is installed
alert 'init' "wireguard - vpn service"
if ! command -v wg &> /dev/null
then
    alert 'warning' "WireGuard is not installed. Installing..."

    sudo apt update
    # Install UFW
    sudo apt install wireguard -y

    # Update package index and install WireGuard
    alert 'success' "WireGuard installed successfully."
else
    alert 'success' "WireGuard is already installed."
fi

# Check if ripgrep is installed
alert 'init' "ripgrep - super fast grep"
if ! command -v rg &> /dev/null
then
    alert 'warning' "ripgrep is not installed. Installing..."

    sudo apt update
    # Install UFW
    sudo apt install ripgrep -y

    # Update package index and install WireGuard
    alert 'success' "ripgrep installed successfully."
else
    alert 'success' "ripgrep is already installed."
fi


# Update netplan configuration file
netplan_file="/etc/netplan/01-netcfg.yaml"
netplan_static_file="etc/netplan/static.yaml"

if [ -f "$netplan_static_file" ]; then
    alert 'success' "Netplan static configuration file found. All done."
    exit 1
fi

if [ ! -f "$netplan_file" ]; then
    alert 'warning' "Netplan configuration file not found: $netplan_file. Exiting"
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
echo "Ethernet Interface: $interface_name"
echo "IP Address: $ip_address"
echo "Gateway IP: $gateway_ip"

# Update netplan configuration file
netplan_file="/etc/netplan/01-netcfg.yaml"
netplan_static_file="etc/netplan/static.yaml"

if [ ! -f "$netplan_file" ]; then
    alert 'warning' "Netplan configuration file not found: $netplan_file. Exiting"
    exit 1
fi

echo "Updating netplan configuration file: $netplan_file"

# Backup the original file
sudo cp "$netplan_file" "$netplan_file.bak"

# Delete original file
sudo rm "$netplan_file" 

# Copy over base config file
sudo cp "./static.yaml" "$netplan_static_file"

# Update the YAML file with the current IP address
sed -i "s|<INTERFACE_NAME>|$interface_name|g" "$netplan_static_file" 
sed -i "s|<IP_ADDRESS>|$ip_address|g" "$netplan_static_file"
sed -i "s|<GATEWAY_IP>|$gateway_ip|g" config.yaml

# Apply the changes
sudo netplan apply

alert 'success' "Netplan configuration updated successfully."
alert 'success' "current config is: "
sudo cat $netplan_static_file

alert 'warning' "double check this, it can ruin your ssh connection if configurred incorrectly."