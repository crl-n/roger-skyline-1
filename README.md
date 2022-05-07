# roger-skyline-1

## Setting up the VM

For my VM, I use [Debian](https://www.debian.org/distrib/).

**1. Virtual Hard Disk**</br>
When setting up the virtual machine, first you will be asked to configure the virtual hard disk. I use the **VDI-format** for the virtual hard disk file and let it be **8GB** and **fixed size**. I create the virtual disk in the `/Users/user/goinfre/` folder.

**2. Configuring the network**</br>
I set the hostname as the cluster computer name, e.g. `c1r1p1`. I leave the domain name blank, because [one is unlikely to be needed in a project of this scale](https://superuser.com/questions/889456/correct-domain-name-for-a-home-desktop-linux-machine).

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

To configure the SSH we browse to `/etc/ssh` and `sudo chmod +w` the *sshd_config* file so that we can edit it.

#### Connection by public key only
We edit the file so that the following settings are set followingly:
```
PasswordAuthentication no
PubkeyAuthentication yes
```
Now we need a public key from our host system on our virtual machine in order to be able to connect to it. We can copy any public using
```$ ssh-copy-id -i [path to public key] [username]@[static ip of vm] -p [ssh port of vm]```

#### No root login
This can be achieved by changing the `PermitRootLogin` setting in *sshd_config* to `PermitRootLogin no`.

#### Default port
The default port is changed simply by editing the port setting to `Port 50000`. I chose to use 50000 simply becaue it is easy to remember. The only requirement is that the port number is in the range 49152 – 65535.

To finish up we restart the ssh service and reset permissions.
```
$ sudo service ssh restart
$ sudo chmod -w ssh_config
```

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
We can then check the status of our firewall and it's rules with
```
$ sudo ufw status
```







