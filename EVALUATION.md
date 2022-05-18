# Roger Skyline Evaluation

## Checks

### The VM runs on Linux
If it's not Windows or MacOs, it's probably Linux.

### Docker/Vagrant/Traefik
You can use apt to check if Docker or Vagrant are installed.
```
apt list --installed docker vagrant

```
To see if Traefik is installed, you can check using the traefik command. It should say command not found.
```
traefik --help
```

## Install and Update

### 8GB Disk Size
This can be seen in VirtualBox. Go to the storage settings of the VM to see the disk size.

### 4.2GB Partition
On the VM, run
```
sudo fdisk -l
```

### Up-to-date Packages
You can use apt for this. It should say *All packages are up to date.*
```
sudo apt update -y
```
## Network and Security

### DHCP

### SSH Port
Can be checked with the following command.
```
sudo netstat --tcp --programs --numeric | grep ssh
```

### Open Ports
You can use netstat or lsof to see which ports are open.
```
netstat -tunlp
sudo lsof -Pni
```

