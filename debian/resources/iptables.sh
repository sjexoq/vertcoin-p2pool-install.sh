#!/bin/sh

#send a message
echo "Configure IPTables"

#run iptables commands
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 5889 -j ACCEPT
iptables -A INPUT -p tcp --dport 9171 -j ACCEPT
iptables -A INPUT -p tcp --dport 9181 -j ACCEPT
iptables -A INPUT -p tcp --dport 9346 -j ACCEPT
iptables -A INPUT -p tcp --dport 9347 -j ACCEPT
if [ $IPTABLES_SSH = "1" ]; then
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT -s ${REMOTE_IP}
else
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT
fi
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -p tcp --dport 5889 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 9171 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 9181 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 9346 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 9347 -j ACCEPT
ip6tables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y --force-yes  iptables-persistent

# if making iptable changes
#iptables-save >/etc/iptables/rules.v4
#ip6tables-save >/etc/iptables/rules.v6
