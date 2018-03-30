#!/bin/sh

continue=0
while [ $continue != 1 ]; do

	echo "${underline}Would you like to install or upgrade?${normal}"
	echo "${yellow}i) Install fresh installation${normal}"
	echo "${yellow}u) Upgrade existing installation${normal}"
	skip=0
	while [ $skip != 1 ]; do
		read -p "Enter [i|u]: " INSTALL_TYPE		
		if [ ! -z "$INSTALL_TYPE" ]; then
			case "$INSTALL_TYPE" in
				[i]|[u])
				skip=1
				;;
				*)
				echo "Please try again."
				skip=0
				;;
			esac
		else
			echo "Please try again."
			skip=0
		fi
	done
	continue=1
	
done
	
continue=0
while [ $continue != 1 ]; do

	if [ $INSTALL_TYPE = "i" ]; then
	
		skip=0
		while [ $skip != 1 ]; do
			read -p "IP Tables will be configured, would you like to restrict SSH access? (recommended: y) [y|n]: " IPTABLES_SSH
			if [ ! -z "$IPTABLES_SSH" ]; then
				case "$IPTABLES_SSH" in
					[y]|[n])
					skip=1
					;;
					*)
					echo "Please try again."
					skip=0
					;;
				esac
			else
				echo "Please try again."
				skip=0
			fi
		done
		
		if [ $IPTABLES_SSH = "y" ]; then
		
			skip=0
			while [ $skip != 1 ]; do
				read -p "Enter your remote IP address to restrict SSH access from: " REMOTE_IP
				if [ ! -z "$REMOTE_IP" ]; then
					skip=1
				else
					echo "Please try again."
					skip=0
				fi
			done
		
		fi
		
		skip=0
		while [ $skip != 1 ]; do
			read -p "Enter P2Pool Max Incoming Connections (default 40) [2-200]: " MAX_CONNS_TO_REPLACE
			if [ ! -z "$MAX_CONNS_TO_REPLACE" -a "$MAX_CONNS_TO_REPLACE" -ge 2 -a "$MAX_CONNS_TO_REPLACE" -le 200 ]; then
				skip=1
			else
				echo "Please try again."
				skip=0
			fi
		done
		
		skip=0
		while [ $skip != 1 ]; do
			read -p "Enter P2Pool Max Outgoing Connections (default 6) [2-10]: " OUTGOING_CONNS_TO_REPLACE
			if [ ! -z "$OUTGOING_CONNS_TO_REPLACE" -a "$OUTGOING_CONNS_TO_REPLACE" -ge 2 -a "$OUTGOING_CONNS_TO_REPLACE" -le 10 ]; then
				skip=1
			else
				echo "Please try again."
				skip=0
			fi
		done
		
		skip=0
		while [ $skip != 1 ]; do
			read -p "Enter P2Pool Network 1 (>100MH/s) or 2 (<100MH/s) [1|2]: " NETWORK_TO_REPLACE			
			if [ ! -z "$NETWORK_TO_REPLACE" ]; then
				case "$NETWORK_TO_REPLACE" in
					[1]|[2])
					skip=1
					;;
					*)
					echo "Please try again."
					skip=0
					;;
				esac
			else
				echo "Please try again."
				skip=0
			fi
		done
		if [ $NETWORK_TO_REPLACE = 1 ]; then
			NETWORK_TO_REPLACE="vertcoin"
		else
			NETWORK_TO_REPLACE="vertcoin2"
		fi
		
		skip=0
		while [ $skip != 1 ]; do
			read -p "Enter your P2Pool fee destination address: " FEE_DESTINATION_TO_REPLACE
			if [ ! -z "$FEE_DESTINATION_TO_REPLACE" ]; then
				skip=1
			else
				echo "Please try again."
				skip=0
			fi
		done
		
		skip=0
		while [ $skip != 1 ]; do
			read -p "Enter your P2Pool fee percentage (default 1) [0-50]: " FEE_TO_REPLACE
			if [ ! -z "$FEE_TO_REPLACE" -a "$FEE_TO_REPLACE" -ge 0 -a "$FEE_TO_REPLACE" -le 51 ]; then
				skip=1
			else
				echo "Please try again."
				skip=0
			fi
		done
		
		skip=0
		while [ $skip != 1 ]; do
			read -p "Enter your P2Pool donation percentage (default 1) [0-50]: " DONATION_TO_REPLACE
			if [ ! -z "$DONATION_TO_REPLACE" -a "$DONATION_TO_REPLACE" -ge 0 -a "$DONATION_TO_REPLACE" -le 51 ]; then
				skip=1
			else
				echo "Please try again."
				skip=0
			fi
		done
		continue=1
		
		#generate a random password
		VERTCOIN_USER_PASSWORD=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
		VERTCOIN_RPC_PASSWORD=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

		echo "Exporting Install Variables Only"
		export IPTABLES_SSH=$IPTABLES_SSH
		export REMOTE_IP=$REMOTE_IP
		export MAX_CONNS_TO_REPLACE=$MAX_CONNS_TO_REPLACE
		export OUTGOING_CONNS_TO_REPLACE=$OUTGOING_CONNS_TO_REPLACE
		export NETWORK_TO_REPLACE=$NETWORK_TO_REPLACE
		export FEE_DESTINATION_TO_REPLACE=$FEE_DESTINATION_TO_REPLACE
		export FEE_TO_REPLACE=$FEE_TO_REPLACE
		export DONATION_TO_REPLACE=$DONATION_TO_REPLACE
		export VERTCOIN_USER_PASSWORD=$VERTCOIN_USER_PASSWORD
		export VERTCOIN_RPC_PASSWORD=$VERTCOIN_RPC_PASSWORD

	fi
done
echo "Exporting Other Variables"
export INSTALL_TYPE=$INSTALL_TYPE
