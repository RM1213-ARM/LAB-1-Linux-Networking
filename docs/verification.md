# Project Verification & Testing Log

## Overview
The following tests were conducted to verify the integrity of the inter-subnet routing and the enforcement of the stateful firewall policy. Testing was performed between the Client VM (192.168.10.10) and the Web Server VM (192.168.20.10) via the Linux Router.

## 1. Connectivity & Routing (ICMP)

* Test: Send 4 ICMP echo requests (Ping) from Client to Server.

* Command: ping -c 4 192.168.20.10

* Expected Result: 0% packet loss; successful bidirectional communication.

* Actual Result: PASS

Technical Note: Confirmed that the router is correctly forwarding packets between the two physical interfaces (enp3s0 and enp26s0) with ip_forward enabled.

## 2. Service Access (HTTP/HTTPS)

* Test: Verify web access from Client Subnet to the DMZ Server.

* Command: curl -I http://192.168.20.10

* Expected Result: HTTP 200 OK (successful connection response status code)

* Actual Result: PASS

Technical Note: The stateful inspection rule (ESTABLISHED,RELATED) successfully allowed the server's HTTP response to pass back to the client without needing a manual return rule.

## 3. Security Enforcement (Default Deny)

* Test: Attempt to connect via an unauthorized protocol (Telnet - Port 23).

* Command: telnet 192.168.20.10 23

* Expected Result: Connection timeout; packet dropped by firewall.

* Actual Result: 🛡️ SUCCESS (BLOCKED)

* Log Evidence: Verified in /var/log/syslog on the Router:

** kernel: [FW_REJECT: ] IN=enp3s0 OUT=enp26s0 SRC=192.168.10.10 DST=192.168.20.10 PROTO=TCP DPT=23

## 4. Unidirectional SSH (Lateral Movement Prevention)

* Test A (Admin Access): SSH from Client to Server.

* Result: PASS (Login successful).

* Test B (Security Constraint): SSH from Server back to Client.

* Result: SUCCESS (BLOCKED) (Connection timeout).

## Conclusion: The management plane is isolated. A compromised Web Server cannot initiate an SSH session back into the internal management subnet.

# 5. Static Security Analysis (Anti-Spoofing)

Mechanism: Interface-to-Subnet Binding.

Analysis: While a live spoofing attack was not simulated, the firewall script contains strict -i (input interface) and -s (source IP) pairings. By requiring Subnet A traffic to arrive exclusively via enp3s0, the configuration mathematically prevents an attacker on the Server interface (enp26s0) from successfully routing packets that claim to be from the Client network.
