# Linux-Based Network Routing and Security Lab

## Project Overview
This project demonstrates the implementation of a virtualized network infrastructure using Linux nodes. The primary objective was to configure a secure gateway (Router) to manage traffic between two distinct subnets, implementing stateful traffic filtering and Network Address Translation (NAT).

## Network Architecture
The environment is built within VMware using a segmented topology:

* **Subnet A (Management Zone):** `192.168.10.0/24`
* **Subnet B (Server Zone):** `192.168.20.0/24`
* **Gateway (Router):** * enp2s0: WAN/NAT
    * enp3s0: `192.168.10.1` (Subnet A Gateway)
    * enp26s0: `192.168.20.1` (Subnet B Gateway)

## Technical Implementation

### 1. Routing & IP Forwarding
The Linux kernel was configured to enable IPv4 forwarding, allowing the router to act as the Layer 3 jump point between the Client and Server segments.
* **Configuration:** Persistent changes made via `sysctl.conf` and Netplan YAML definitions.

### 2. Firewall Logic (iptables)
A "Default Deny" security posture was implemented to ensure only authorized traffic is permitted.
* **Stateful Inspection:** Configured to allow traffic with the state `ESTABLISHED` and `RELATED`.
* **Service Access:** Explicitly allowed TCP Port 80 (HTTP) for the web service and Port 22 (SSH) for administrative access.
* **Protocol Filtering:** ICMP echo-requests are permitted for network diagnostic purposes.

### 3. Network Address Translation (NAT)
Configured IP Masquerading using iptables on the Router's WAN interface. This allows the internal private subnets ('192.168.10.0/24' and '192.168.20.0/24') to reach external resources by sharing the Router's assigned hotspot IP, effectively hiding the internal topology from the external network.

## Verification and Testing
To validate the configuration, the following connectivity tests were executed from the Management node (`192.168.10.10`):

| Test Case | Command | Expected Result | Status |
| :--- | :--- | :--- | :--- |
| Gateway Reachability | `ping -c 3 192.168.10.1` | 0% Packet Loss | PASS |
| Inter-Subnet Routing | `ping -c 3 192.168.20.10` | 0% Packet Loss | PASS |
| Web Service Access | `curl -I 192.168.20.10` | HTTP 200 OK | PASS |
| Security Filtering | `nmap -p 445 192.168.20.10` | Filtered/Closed | PASS |

## Repository Structure
* `/scripts`: Shell scripts for automated iptables deployment.
* `/configs`: Netplan YAML files and Nginx site configurations.
* `/docs`: Detailed network diagrams and testing logs.
