# Roger Skyline Evaluation

## Checks

### Docker/Vagrant/Traefik
You can use apt to check if Docker or Vagrant are installed.
```
apt list --installed docker vagrant

```
To see if Traefik is installed, you can check using the traefik command. It should say command not found.
```
traefik --help
```

## Open Ports
You can use netstat to see which ports are open.
```
netstat -tunlp
```

