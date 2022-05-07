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
So where do these addresses come from? The two latter fields of the static IP address are essentially made up. The first two fields follow the same pattern (10.1X where X is the number of the cluster) as the local addresses of other cluster computers. We are asked to configure a netmask in \30. This piece of information gives us the netmask address, [see here for more information](https://www.aelius.com/njh/subnet_sheet.html).

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

