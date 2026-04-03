#!/bin/bash

# ==========================================================
# SETUP-FIREWALL.SH
# Purpose: Configure Inter-Subnet Routing and Stateful Security
# ==========================================================

# 1. Define Variables 
INT_A="enp3s0"           # Interface for Management Subnet
INT_B="enp26s0"          # Interface for Server Subnet
SUBNET_A="192.168.10.0/24"
SUBNET_B="192.168.20.0/24"

# 2. Global Routing Switch, allows for routing traffic between networkadapters
sudo sysctl -w net.ipv4.ip_forward=1

# 3. Security Reset (deleting possible existing rules)
sudo iptables -F

# 4. Default Deny Policy (Enfocrces 'Zero Trust' best practice)
sudo iptables -P FORWARD DROP

# 5. Stateful Inspection Rule ("Firewall remembers connections and allows return traffic")
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 6. Specific Allow Rules (Using set variables)

# Rule: Allow Ping between Subnets (Connectivity testing and network diagnostics)
sudo iptables -A FORWARD -p icmp -s $SUBNET_A -d $SUBNET_B -j ACCEPT
sudo iptables -A FORWARD -p icmp -s $SUBNET_B -d $SUBNET_A -j ACCEPT

# Rule: Allow HTTP (Web) Traffic (Only allowing http requests to the webserver from client VM)
sudo iptables -A FORWARD -i $INT_A -o $INT_B -p tcp -s $SUBNET_A -d $SUBNET_B --dport 80 -j ACCEPT
sudo iptables -A FORWARD -i $INT_A -o $INT_B -p tcp -s $SUBNET_A -d $SUBNET_B --dport 443 -j ACCEPT

# Rule: Allow SSH (TCP) Traffic (Only allowing administrative access for remote management from Management VM)
sudo iptables -A FORWARD -i $INT_A -o $INT_B -p tcp -s $SUBNET_A -d $SUBNET_B --dport 22 -j ACCEPT

# Rule: Log rejected traffic (Provides logging for troubleshooting/security)
sudo iptables -A FORWARD -j LOG --log-prefix "FW_REJECT: "

#Confirmation that configuration was successful
echo "Firewall successfully deployed with Subnet Isolation."
