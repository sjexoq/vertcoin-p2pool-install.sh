# vertcoin-p2pool-install.sh
Vertcoin and P2Pool Debian 8 Installation Script
--------------------------------------

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

Donations
--------------------------------------
SJExoQ: VTC VjWdJU5DwPQnent5sZdkwwdvHPTNLX7Wa6

Vertcoin: VTC 1HNeqi3pJRNvXybNX4FKzZgYJsdTSqJTbk
