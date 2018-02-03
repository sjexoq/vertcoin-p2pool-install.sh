#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./resources/colors.sh
. ./resources/config.sh

#Update Debian
verbose "Update Debian"
apt-get upgrade && apt-get update -y --force-yes

#IPTables
resources/iptables.sh

#Preperation
resources/prep.sh

#restart services
systemctl daemon-reload

#Brief post install
if [ $INSTALL_TYPE = "i" ]; then
	echo "Installation Complete"
	echo ""
	echo "   Vertcoin User Password: ${VERTCOIN_USER_PASSWORD}"
	echo "   Vertcoin RPC Password: ${VERTCOIN_RPC_PASSWORD}"
	echo ""
	if [ $IPTABLES_SSH = "1" ]; then
		echo "   Remote SSH Access Restricted to: ${REMOTE_IP}"
	else
		echo "   Remote SSH Access is open, please make sure any users for this system are using a secure password!"
	fi
	echo ""
	echo "   Vertcoin Config Directory: /home/vertcoin/.vertcoin/vertcoin.conf"
	echo "   Vertcoin\P2Pool Screen Logs Directory: /home/vertcoin/"
	echo ""
	echo "   Vertcoin Service Location: /etc/init.d/p2pool"
	echo "   P2Pool Service Location: /etc/init.d/vertcoind"
	echo ""
else
	echo "Upgrade Complete"
	echo ""
fi
