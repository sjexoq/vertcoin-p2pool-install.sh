#!/bin/sh

if [ $INSTALL_TYPE = "i" ]; then

	#send a message
	echo "Preparing the system\n"

	#install dependencies
	echo 'Installing dependencies'
	apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-all-dev git
	apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

	#Stop service if already running
	service p2pool stop
	service vertcoind stop

	#Vertcoin Install
	cd /usr/src
	rm -rf /usr/src/vertcoin-core
	git clone https://github.com/vertcoin-project/vertcoin-core
	BITCOIN_ROOT=/usr/src/vertcoin-core
	# Pick some path to install BDB to, here we create a directory within the bitcoin directory
	BDB_PREFIX="${BITCOIN_ROOT}/db4"
	mkdir -p $BDB_PREFIX
	# Fetch the source and verify that it is not tampered with
	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c
	# -> db-4.8.30.NC.tar.gz: OK
	tar -xzvf db-4.8.30.NC.tar.gz
	# Build the library and install to our prefix
	cd db-4.8.30.NC/build_unix/
	#  Note: Do a static build so that it can be embedded into the executable, instead of having to find a .so at runtime
	../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
	make install
	# Configure Bitcoin Core to use our own-built instance of BDB
	cd $BITCOIN_ROOT
	./autogen.sh
	./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" --without-gui
	make
	make install

	#Add vertcoin user
	sudo adduser vertcoin --gecos "vertcoin" --disabled-password
	echo "vertcoin:${VERTCOIN_USER_PASSWORD}" | sudo chpasswd

	#Configure vertcoin
	rm -rf /home/vertcoin/.vertcoin
	rm -rf /home/vertcoin/.vertcoin
	mkdir /home/vertcoin/.vertcoin
	echo 'daemon=1' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'server=1' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'gen=0' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'port=5889' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'rpcport=5899' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'rpcallowip=127.0.0.1' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'rpcuser=vertcoinuser' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo "rpcpassword=${VERTCOIN_RPC_PASSWORD}" >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'rpcworkqueue=300' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'blockmaxsize=1000000' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'mintxfee=0.00001' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'minrelaytxfee=0.00001' >> /home/vertcoin/.vertcoin/vertcoin.conf
	echo 'maxconnections=200' >> /home/vertcoin/.vertcoin/vertcoin.conf

	#Link vertcoin config
	ln /home/vertcoin/.vertcoin/vertcoin.conf /root/.vertcoin/vertcoin.conf

	#P2pool
	apt-get install -y python-zope.interface python-twisted python-twisted-web
	cd /usr/src
	rm -rf /usr/src/p2pool-vtc
	git clone https://github.com/vertcoin-project/p2pool-vtc
	cd p2pool-vtc
	cd lyra2re-hash-python
	git submodule init
	git submodule update
	python setup.py install

	#Install screen log
	apt-get install -y screen

	#P2pool GUI
	cd /usr/src
	rm -rf /usr/src/p2pool-ui-punchy
	git clone https://github.com/justino/p2pool-ui-punchy
	rm -rf /usr/src/p2pool-vtc/web-static
	mkdir /usr/src/p2pool-vtc/web-static
	cp -R p2pool-ui-punchy/* /usr/src/p2pool-vtc/web-static/
	chown vertcoin:vertcoin -R /usr/src/p2pool-vtc
	
	#Vertcoind
	rm -rf /usr/bin/vertcoind
	cp /usr/src/vertcoin-core/src/vertcoind /usr/bin/vertcoind

	#Vertcoind service
	rm /etc/init.d/vertcoind
	touch /etc/init.d/vertcoind
	chmod a+x /etc/init.d/vertcoind
	update-rc.d vertcoind defaults
	rm /etc/init.d/vertcoind
	cp /usr/src/vertcoin-p2pool-install.sh/debian/resources/init.d/vertcoind /etc/init.d/vertcoind

	#P2pool service
	rm /etc/init.d/p2pool
	touch /etc/init.d/p2pool
	chmod a+x /etc/init.d/p2pool
	update-rc.d p2pool defaults 
	rm /etc/init.d/p2pool
	cp /usr/src/vertcoin-p2pool-install.sh/debian/resources/init.d/p2pool /etc/init.d/p2pool
	sed -i "s/MAX_CONNS_TO_REPLACE/${MAX_CONNS_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/OUTGOING_CONNS_TO_REPLACE/${OUTGOING_CONNS_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/NETWORK_TO_REPLACE/${NETWORK_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/FEE_DESTINATION_TO_REPLACE/${FEE_DESTINATION_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/FEE_TO_REPLACE/${FEE_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/DONATION_TO_REPLACE/${DONATION_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/VERTCOIN_RPC_PASSWORD_TO_REPLACE/${VERTCOIN_RPC_PASSWORD}/" /etc/init.d/p2pool
	chown vertcoin:vertcoin -R /usr/src/p2pool-vtc
	chown vertcoin:vertcoin -R /usr/bin/vertcoind
	chown vertcoin:vertcoin -R /home/vertcoin/.vertcoin
	chmod 755 /etc/init.d/vertcoind
	chmod 755 /etc/init.d/p2pool
	systemctl daemon-reload
	echo "Starting Vertcoind and P2Pool\n"
	echo "Please be patient, Vertcoind may take a few hours to sync the blockchain, during this time P2Pool will not be available.\n"
	service vertcoind start
	service p2pool start

	#Configure screen logs: /home/vertcoin/screenlog.0
	rm /home/vertcoin/screenlog-rotate.conf
	echo '/home/vertcoin/screenlog.0 {' >> /home/vertcoin/screenlog-rotate.conf
	echo '  size 100M' >> /home/vertcoin/screenlog-rotate.conf
	echo '}' >> /home/vertcoin/screenlog-rotate.conf
	logrotate /home/vertcoin/screenlog-rotate.conf

	#Update Crontab Jobs
	echo "Adding Cron Jobs"
	rm /tmp/cronjobs
	conjob=$(printf MTAsMjAsMzAsNDAsNTAgKiAqICogKiAvdXNyL2Jpbi9sb2dyb3RhdGUgL2hvbWUvdmVydGNvaW4vc2NyZWVubG9nLXJvdGF0ZS5jb25m | base64 --decode)
	echo "${conjob}" >> /tmp/cronjobs
	crontab /tmp/cronjobs
	rm /tmp/cronjobs
	unset conjob
	
fi

if [ $INSTALL_TYPE = "u" ]; then

	echo "Stopping Vertcoind and P2Pool\n"
	service p2pool stop
	service vertcoind stop
	sleep 10
	echo "Stopping Vertcoind and P2Pool.\n"
	sleep 10
	echo "Stopping Vertcoind and P2Pool..\n"
	sleep 10
	echo "Stopping Vertcoind and P2Pool...\n"
	sleep 10
	echo "Stopping Vertcoind and P2Pool....\n"
	pidofp2pool = pidof python
	if [ ! -z "$pidofp2pool" ]; then
		kill -9 pidofp2pool
	fi
	pidofvertcoind = pidof vertcoind
	if [ ! -z "$pidofvertcoind" ]; then
		kill -9 pidofvertcoind
	fi
	sleep 10
	echo "Preparing Upgrade\n"
	
	#Vertcoin
	cd /usr/src/vertcoin-core
	git remote set-url origin https://github.com/vertcoin-project/vertcoin-core
	git pull
	BITCOIN_ROOT=/usr/src/vertcoin
	# Pick some path to install BDB to, here we create a directory within the bitcoin directory
	BDB_PREFIX="${BITCOIN_ROOT}/db4"
	mkdir -p $BDB_PREFIX
	# Fetch the source and verify that it is not tampered with
	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c
	# -> db-4.8.30.NC.tar.gz: OK
	tar -xzvf db-4.8.30.NC.tar.gz
	# Build the library and install to our prefix
	cd db-4.8.30.NC/build_unix/
	#  Note: Do a static build so that it can be embedded into the executable, instead of having to find a .so at runtime
	../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
	make install
	# Configure Bitcoin Core to use our own-built instance of BDB
	cd $BITCOIN_ROOT
	./autogen.sh
	./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" --without-gui
	make
	make install
	
	#P2pool
	cd /usr/src/p2pool-vtc
	git remote set-url origin https://github.com/vertcoin-project/p2pool-vtc
	git pull
	cd lyra2re-hash-python
	git submodule init
	git submodule update
	python setup.py install
	
	#P2Pool GUI
	cd /usr/src/p2pool-ui-punchy
	git pull
	rm -rf /usr/src/p2pool-vtc/web-static/
	mkdir /usr/src/p2pool-vtc/web-static
	cp -R p2pool-ui-punchy/* /usr/src/p2pool-vtc/web-static/
	chown vertcoin:vertcoin -R /usr/src/p2pool-vtc
	
	#Vertcoin
	rm -rf /usr/bin/vertcoind
	cp /usr/src/vertcoin-core/src/vertcoind /usr/bin/vertcoind
	
	echo "Starting Vertcoind and P2Pool\n"
	echo "Please be patient, Vertcoind may take a few hours to sync the blockchain, during this time P2Pool will not be available.\n"
	service vertcoind start
	service p2pool start

fi
