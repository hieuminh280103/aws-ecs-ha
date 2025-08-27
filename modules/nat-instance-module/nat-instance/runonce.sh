#!/bin/bash -x
sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables
sudo sysctl -q -w net.ipv4.ip_forward=1
sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo service iptables save