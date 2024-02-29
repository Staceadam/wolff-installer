#!/bin/bash

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