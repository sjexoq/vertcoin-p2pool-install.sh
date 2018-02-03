# vertcoin-p2pool-install.sh
Vertcoin and P2Pool Debian 8 Installation Script
--------------------------------------

This install script that has been designed to be an fast, simple, and modular way to to install Vertcoin and P2Pool. Start with a minimal install of Debian 8 with SSH enabled. Run the following commands under root. It installs Vertcoin, P2Pool source package and its dependencies.

```bash
sudo -i
cd /tmp
apt-get install curl
curl "https://raw.githubusercontent.com/sjexoq/vertcoin-p2pool-install.sh/master/install.sh" > install.sh
sh install.sh
```
Once installation has completed, make a note of any passwords and directories.
