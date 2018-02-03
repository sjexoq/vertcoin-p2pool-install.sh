#!/bin/sh

if [ $INSTALL_TYPE = "i" ]; then

	#send a message
	echo "Preparing the system\n"

	#install dependencies
	echo 'Installing dependencies'
	apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-all-dev git
	apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

	#Vertcoin Install
	cd /usr/src
	git clone https://github.com/vertcoin/vertcoin
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

	#Add vertcoin user
	sudo adduser vertcoin --gecos "vertcoin" --disabled-password
	echo "vertcoin:${VERTCOIN_USER_PASSWORD}" | sudo chpasswd

	#Configure vertcoin
	mkdir /home/vertcoin/.vertcoin
	rm /home/vertcoin/.vertcoin/vertcoin.conf
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
	git clone https://github.com/vertcoin/p2pool-vtc
	cd p2pool-vtc
	cd lyra2re-hash-python
	git submodule init
	git submodule update
	python setup.py install

	#Install screen log
	apt-get install -y screen

	#P2pool GUI
	cd /usr/src
	git clone https://github.com/justino/p2pool-ui-punchy
	cp -R p2pool-ui-punchy/* /usr/src/p2pool-vtc/web-static/ 
	cp /usr/src/vertcoin/src/vertcoind /usr/bin/vertcoind

	#Vertcoind service
	rm /etc/init.d/vertcoind
	touch /etc/init.d/vertcoind
	chmod a+x /etc/init.d/vertcoind
	update-rc.d vertcoind defaults 
	cp cp /usr/src/vertcoin-p2pool-install.sh/resources/init.d/vertcoind /etc/init.d/vertcoind

	#P2pool service
	rm /etc/init.d/p2pool
	touch /etc/init.d/p2pool
	chmod a+x /etc/init.d/p2pool
	update-rc.d p2pool defaults 
	cp cp /usr/src/vertcoin-p2pool-install.sh/resources/init.d/p2pool /etc/init.d/p2pool
	sed -i "s/MAX_CONNS_TO_REPLACE/${MAX_CONNS_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/OUTGOING_CONNS_TO_REPLACE/${OUTGOING_CONNS_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/NETWORK_TO_REPLACE/${NETWORK_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/FEE_DESTINATION_TO_REPLACE/${FEE_DESTINATION_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/FEE_TO_REPLACE/${FEE_TO_REPLACE}/" /etc/init.d/p2pool
	sed -i "s/DONATION_TO_REPLACE/${DONATION_TO_REPLACE}/" /etc/init.d/p2pool
	chown vertcoin:vertcoin -R /usr/src/p2pool-vtc
	chown vertcoin:vertcoin -R /usr/bin/vertcoind
	chmod 755 /etc/init.d/vertcoind
	chmod 755 /etc/init.d/p2pool
	systemctl daemon-reload
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

	service p2pool stop
	service vertcoind stop
	
	#Vertcoin
	cd /usr/src/vertcoin
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
	git pull
	cd lyra2re-hash-python
	git submodule init
	git submodule update
	python setup.py install
	
	#P2Pool GUI
	cd /usr/src/p2pool-ui-punchy
	git pull
	rm -rf /usr/src/p2pool-vtc/web-static/
	cp -R p2pool-ui-punchy/* /usr/src/p2pool-vtc/web-static/
	
	#Vertcoin
	rm -rf /usr/bin/vertcoind
	cp /usr/src/vertcoin/src/vertcoind /usr/bin/vertcoind
	
	service vertcoind start
	service p2pool start

fi
