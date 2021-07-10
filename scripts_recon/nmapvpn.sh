#!/bin/bash
openvpn --ifconfig 10.200.0.2 10.200.0.1 --dev tun --secret secret.key --remote 45.62.212.184 --rport 443 --proto tcp-client   --cipher AES-256-CBC
