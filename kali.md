## Connecting to Kali to update and install the desktop environment

```ssh svradmin@PublicIPAddressOfAzureFirewall```

```Password: H@ppytimes123!```

```
wget --no-check-certificate https://http.kali.org/kali/pool/main/k/kali-archive-keyring/kali-archive-keyring_2022.1_all.deb
sudo apt install ./kali-archive-keyring_2022.1_all.deb
sudo apt-get update
sudo apt-get -y install xrdp
sudo systemctl enable xrdp
echo xfce4-session >~/.xsession
sudo service xrdp restart
```
* Create an entry in the HOSTS file (/etc/hosts) on Kali VM to map a name to the Public IP address of the OWASP Juice Shop site published on Application Gateway. Add the linne below at the end of the file:

```<Public IP Address Of the Application Gateway>  juiceshopthruazwaf.com```

## Connecting to the Graphical Interface of Kali

* RDP to the Public IP Address of Azure Firewall at the Port 33892
* When prompted to choose the setup for the first startup, click to select “Use default config”  
