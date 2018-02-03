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
