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
I install the **standard system utilities** and the **ssh server**.

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

Next we will set up a static IP. The IP I will be using is `10.11.203.111`. If you are wondering where this IP comes from, it is essentially made up. To do this, we'll browse to `/etc/network/`. Here, we modify the *interfaces file*.
