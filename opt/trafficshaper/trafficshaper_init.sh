#!/bin/bash
trap "" SIGINT SIGTERM SIGSTOP SIGTSTP

# Setting interface-variables for routin packages
echo -en "\033[1;32mNetwork settings... "
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/wlan0/send_redirects
echo 1 > /proc/sys/net/ipv4/ip_no_pmtu_disc
echo -e "Done\033[0m"

echo -en "\033[1;32mMTU=1500 settings... "
for i in $var; 
do
	intf="/proc/sys/net/ipv4/conf/$i/send_redirects";
	echo 0 > $intf
	ifconfig $i mtu 1500
done
echo -e "Done\033[0m"

# Start access-point daemon
service hostapd start
# Activate NAT on wlan0, always heading in direction "internet"
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE > /dev/null 2>&1

