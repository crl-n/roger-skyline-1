# roger-skyline-1

## Setting up the VM

For my VM, I use [Debian](https://www.debian.org/distrib/).

**1. Virtual Hard Disk**</br>
When setting up the virtual machine, first you will be asked to configure the virtual hard disk. I use the **VDI-format** for the virtual hard disk file and let it be **8GB** and **fixed size**. I create the virtual disk in the `/Users/user/goinfre/` folder. 

**2. Configuring the network**</br>
I set the hostname as `debian`. I leave the domain name blank, because [one is unlikely to be needed in a project of this scale](https://superuser.com/questions/889456/correct-domain-name-for-a-home-desktop-linux-machine).

**3. Partioning of the virtual hard disk**</br>
I manually partion the virtual hard disk into two partions (sizes 4.2GB, 3.4GB and 1.0GB for swap). See picture below.
<img width="798" alt="image" src="https://user-images.githubusercontent.com/65853349/166874309-da892ce0-a96e-45ea-87f5-a271085ee87b.png">

**4. Software Selection**</br>
I install the **standard system utilities** and the **ssh server**. Other software can later be installed using `apt install`.

## Network and Security

### 1. Creating a non-root user with sudoer rights
Sudo doesn't come pre-installed, so to start we have to install sudo. To do this, we need to be root. For this we use the command:
```
$ su
```
Then we installl sudo using apt.
```
$ apt update -y
$ apt upgrade -y
$ apt install sudo -y
```
Then we have to edit the sudoers file (here i use nano, because vim is not installed yet).
```
$ cd /etc
$ chmod +w sudoers
$ nano sudoers
```
In nano, add a line under the *user privileges* section.
```
cnysten ALL=(ALL:ALL) ALL
```
Then restore the old permissions and exit root.
```
$ chmod -w sudoers
$ exit
```
Now commands requiring super user rights can be run by prefixing them with sudo. For example, installing new packages requires super user rights. I can now install the packages I will be using for the rest of the project.
```
$ sudo apt install vim net-tools -y
```

### 2. Setting up static IP
To begin with, we will change the VM adapter setting from NAT to **Bridged Adapter**.
<img width="649" alt="image" src="https://user-images.githubusercontent.com/65853349/167119893-49f59e57-16f2-4ec6-ba44-01e06719425d.png">

Next we will manually configure our network interface to use a static IP. To do this, we'll browse to `/etc/network/`. Here, we modify the the primary network interface configuration in the file *interfaces*.
```
# The primary network interface
auto enp0s3
```
Then we add a file to the *interfaces.d* directory.
```
$ cd interfaces.d
$ vim enp0s3
```
... adding the following lines:
```
iface enp0s3 inet static
    address 10.11.203.111
    netmask 255.255.255.252
    gateway 10.11.254.254
```
So where do these addresses come from? 
<br>
**IP:** The two latter fields of the static IP address are essentially made up. The first two fields follow the same pattern (10.1X where X is the number of the cluster) as the local addresses of other cluster computers. 
<br>
**Netmask:** We are asked to configure a netmask in \30. This piece of information gives us the netmask address, [see here for more information](https://www.aelius.com/njh/subnet_sheet.html).
<br>
**Gateway:** We can look up the gateway address using a command we're familiar with from init (network/04) `netstat -nr | grep 'default.*en0'
`. 

Now we have to restart the networking service to get the changes into effect.
```
$ sudo service networking restart
```
We can then check that the network service is up and running and that our new static IP is being used by the networking service.
```
$ sudo service networking status
$ sudo ifconfig
```
As a last check, we should make sure everything works correctly by for example pinging or accessing any website.
```
$ ping google.com
```

### 3. Configuring SSH

Before we turn of password authentication we need a public key from our host system on our virtual machine in order to be able to connect to it later without the use of a password. We can copy any public key using
```
$ ssh-copy-id -i [path to public key] [username]@[static ip of vm] -p [ssh port of vm]
```
If you get a warning, saying that remote host identification has changed (this could happen if you created a new VM with the same IP you used previously), you need to add the new fingerprint of the VM to your known hosts on the host system.
```
$ ssh-keyscan -H 10.11.203.111 >> ~/.ssh/known_hosts
```

Great. Now we can proceed to configure the SSH. Browse to `/etc/ssh` and `sudo chmod +w` the *sshd_config* file so that we can edit it.

#### Connection by public key only
We edit the file so that the following settings are set followingly:
```
PasswordAuthentication no
PubkeyAuthentication yes
```

#### No root login
This can be achieved by changing the `PermitRootLogin` setting in *sshd_config* to `PermitRootLogin no`.

#### Default port
The default port is changed simply by editing the port setting to `Port 50000`. I chose to use 50000 simply becaue it is easy to remember. The only requirement is that the port number is in the range 49152 – 65535.

To finish up we restart the ssh service and reset permissions.
```
$ sudo service ssh restart
$ sudo chmod -w ssh_config
```

#### Troubleshooting
If you are having issues connecting by public key you can use the `-vvv` flag of the `ssh` command to debug the ssh connection. In the debug output you can see which keys are being used for authentication. Make sure that the correct host key is in the *known_hosts* file of the cluster computer and that the correct __public__ key is in the *authorized_keys* on the VM.

### 4. Firewall set up
We can use *ufw* to set up our firewall rules. First, we need to install ufw.
```
$ sudo apt install ufw
```
We then deny all incoming connection and allow all outgoing connections by default.
```
$ sudo ufw default deny incoming
$ sudo ufw default allow outgoing
```
On top of these default settings, we explicilty allow connections for HTTP, HTTPS and SSH.
```
$ sudo ufw allow 50000/tcp
$ sudo ufw allow 80/tcp
$ sudo ufw allow 443/tcp
```
We can then enable ufw and check the status of our firewall and it's rules with
```
$ sudo ufw enable
$ sudo ufw status
```

### 5. DOS protection
We can use fail2ban to set up rules that protect us from DOS attacks. First, install fail2ban.
```
$ sudo apt install fail2ban
```
To configure fail2ban, browse to `/etc/fail2ban/`. Here, there is a file called *jail.conf*. Copy this file and name the copy *jail.local*.
```
$ sudo cp jail.conf jail.local
```
Find the right part of the file and add configuration for SSH.
```
#
# SSH servers
#

[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
mode   = agressive
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxentry = 3
bantime = 600
```
And then do the same for HTTP and HTTPS.
```
# Protect HTTP and HTTPS (HTTP)

[http-get-dos]

enabled = true
port = http,https
filter = http-get-dos
logpath = /var/log/apache2/access.log
maxentry = 300
findtime = 300
bantime = 600
action = iptables[name=HTTP, port=http, protocol=tcp]
```
Lastly, we need to create the http-get-dos filter we just specified in the configuration. Create the file `/etc/fail2ban/filter.d/http-get-dos.conf`.
```
[Definition]

failregex = ^<HOST> -.*"GET.*
ignoreregex =
```

For more info on configuring fail2ban, [check out this guide](https://upcloud.com/community/tutorials/install-fail2ban-debian/).

#### Testing DOS protection
I used [slowloris](https://github.com/gkbrk/slowloris) to test my DOS protection. It is very easy to use. Run the script and give it your VM's static IP as the argument. Fail2ban should ban the attacker IP and you should see `Socket count: 0` in the terminal running slowloris. You can check fail2ban logs using `sudo tail -f /var/log/fail2ban.log`

To unban yourself you don't have to wait for the bantime to be over.
```
$ sudo fail2ban-client set jail_name unbanip xxx.xxx.xxx.xxx
```

### 6. Port scan protection
You can use psad to protect from port scans.
```sudo apt install psad```

Next we have to configure psad by editing `/etc/psad/psad.conf`.

I edited the config followingly:
```
EMAIL_ADDRESSES			root@debian.lan;
HOSTNAME			debian;
PORT_RANGE_SCAN_THRESHOLD	1;
IPT_SYSLOG_FILE			/var/log/syslog;
MIN_DANGER_LEVEL		1;
ENABLE_AUTO_IDS			Y;
AUTO_IDS_DANGER_LEVEL		1;
AUTO_BLOCK_TIMEOUT		300;
```

You can [read more about configuring psad here](https://www.digitalocean.com/community/tutorials/how-to-use-psad-to-detect-network-intrusion-attempts-on-an-ubuntu-vps).

That's it! Scanning the ports of the VM should now get you banned. You can easily test this with a port scanner such as *nmap*.
```
$ nmap 10.1x.xxx.xxx
```

You can see that the IP has been blocked in `/var/log/psad/auto_blocked_iptables`. Reboot the VM to drop the ban.

### 7. Stopping unneeded services
We can list enabled services using `sudo systemctl list-unit-files --type=service --state=enabled --all`.
<img width="394" alt="image" src="https://user-images.githubusercontent.com/65853349/167374454-fd873a69-3d96-42b3-978d-27c385c030ee.png">

For this project, we need at least the following services.
```
apache2
cron
fail2ban
getty
networking
ssh
ufw
```
Services can be disabled using `sudo systemctl disable [service name]`

### 8. Package update script

Make a script to update packages using apt. Something like the script below, for instance.
```
#!/bin/sh
echo "[`date`] sudo apt update -y" >> /var/log/update_script.log
echo "`sudo apt update -y`" >> /var/log/update_script.log
echo "[`date`] sudo apt update -y" >> /var/log/update_script.log
echo "`sudo apt update -y`" >> /var/log/update_script.log
```

Add the following lines to your crontab to schedule the task.
```
@reboot sh /usr/local/bin/package_update.sh &
0 4 * * 1 sh /usr/local/bin/package_update.sh &
```
If the script is stored remotely, it can be deployed over ssh.
```
$ scp -P 50000 package_update.sh cnysten@10.11.203.111:/home/cnysten
$ ssh -t -p 50000 cnysten@10.11.203.111 "sudo mv package_update.sh /usr/local/bin/"
```

### 9. Crontab script

Create the script. Mine looks like this.
```
#!/bin/sh
CRONTAB=/var/spool/cron/crontabs/root
BACKUP=/var/spool/cron/crontabs/backup
MESSAGE="There has been a change to the crontab."

echo 'Looking for changes in crontab...'

if [ ! -e $BACKUP ]; then
	echo 'No previous backup found, creating backup...'
	cp $CRONTAB $BACKUP
	echo 'Exiting...'
	exit 0
fi

DIFF=$(diff $CRONTAB $BACKUP)

echo 'Checking diff...'

if [ "$DIFF" != "" ]; then
	echo MESSAGE | mail -s 'Crontab change' root@debian.lan
fi

cp $CRONTAB $BACKUP
```

Add the following lines to your crontab to schedule the task.
```
0 0 * * * sh /usr/local/bin/monitor_crontab.sh &
```

Next we need to configure our system to handle the emails. For this we need mailutils and postfix.
```
$ sudo apt install mailutils postfix
```
In the postfix installation, choose **local only** and set the *system mail name* to **debian.lan**. 

Edit */etc/aliases*, change the line with `root:` to `root: root@debian.lan`. Run `sudo newaliases` to get the changes into effect.

Now you should be able to send mail to `root@debian.lan`. These messages can be viewed by logging in as root and using `mailx`.

For debugging issues with mailing it can be useful to look at the mail logs.
```
$ sudo tail -f /var/log/mail.log
```

## Web part

First, we install Apache2. I used [this guide](https://medium.com/swlh/apache-for-beginners-9d104225ec89) to configure my server.
```
$ sudo apt install apache2
```
Apache2 stores the default website in `/var/www/html/`. Out of the box, it contains a default *index.html* file. We replace this on with our own.

To copy the web app folder over SSH use scp.
```
$ tar xvf webapp.tar.gz --directory=webapp .
$ scp -P 50000 webapp.tar.gz cnysten@10.11.203.111:/home/cnysten
```

### SSL
I used this [guide](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-16-04) to set up the self-signed ssl certificate.
First, we have to enable the ssl module of apache and create a key and a certificate using openssl.
```
$ sudo a2enmod ssl
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
```
Then create a file `/etc/apache2/sites-available/10.1x.xxx.xxx.conf`.
```
<VirtualHost *:443>
	ServerName 10.11.203.111
	DocumentRoot /var/www/html/

	SSLEngine on
	SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
	SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
<VirtualHost *:80>
	ServerName 10.11.203.111
	Redirect / https://10.11.203.111/
</VirtualHost>
```
Use `sudo apache2ctl configtest` to test your config. You should get a message that looks something like this.
```
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message
Syntax OK
```
Now run the command `sudo a2ensite 10.1x.xxx.xxx` and then `sudo systemctl reload apache2` to restart your server.

## Deployment part
For automatic deployment I've created a script that will deploy the website over SSH. The user is required to run the script when a change is wished to be deployed to the remote server. See *deploy.sh*.
