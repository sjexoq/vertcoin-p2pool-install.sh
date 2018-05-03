# vertcoin-p2pool-install.sh
Vertcoin and P2Pool Debian 8 Installation Script
--------------------------------------

This script is currently in Beta for testing purposes only and not yet suitable for production.

This install script has been designed to be a fast, simple way to to install Vertcoin and P2Pool. Start with a minimal net install of Debian 8 with SSH enabled. Run the following commands under root. It installs Vertcoin, P2Pool and its dependencies. Minimum 2GB RAM required, 4GB RAM recommended.

https://www.debian.org/releases/jessie/debian-installer/

```bash
sudo -i
cd /tmp
apt-get install curl
curl "https://raw.githubusercontent.com/sjexoq/vertcoin-p2pool-install.sh/master/install.sh" > install.sh
sh install.sh
```
Once installation has completed, make a note of any passwords and directories.

Ports
--------------------------------------
The following public TCP ports must be open\forwarded on your firewall to the Vertcoin\P2Pool node:

- 5889 (Vertcoin)

- 9171 (P2Pool network 1)

- 9346 (P2Pool network 1)

- 9181 (P2Pool network 2)

- 9347 (P2Pool network 2)

Donations
--------------------------------------
SJExoQ: VTC VjWdJU5DwPQnent5sZdkwwdvHPTNLX7Wa6

Vertcoin: VTC 1HNeqi3pJRNvXybNX4FKzZgYJsdTSqJTbk
