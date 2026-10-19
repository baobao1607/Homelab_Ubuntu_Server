# Connect the Ubuntu Server to Wi-Fi using netplan

## Checking the network configuration files

1. List the files in `/etc/netplan/`:

```bash
   ls /etc/netplan/
```

2. Back up the original file in case you need to revert:

```bash
   sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
```

3. Edit the network configuration file:

```bash
   sudo vim /etc/netplan/00-installer-config.yaml
```

```yaml
   network:
     version: 2
     wifis:
       wlp1s0:
         addresses:
           - 192.168.4.99/22
         routes:
           - to: default
             via: 192.168.4.1
         nameservers:
           addresses: [192.168.4.1, 1.1.1.1, 8.8.8.8]
         optional: true
         access-points:
           "***":
             password: "***"
```

   This sets a static IP address for the server, sets the default gateway, and points to the DNS servers.

4. Restrict the file permissions:

```bash
   sudo chmod 600 /etc/netplan/00-installer-config.yaml
```

5. Test the configuration (it rolls back automatically unless you confirm):

```bash
   sudo netplan try
```

6. Apply the network configuration:

```bash
   sudo netplan apply
```

7. Test that the network works:

```bash
   ping -c 4 192.168.4.1
   ping -c 4 1.1.1.1
   ping -c 4 google.com
```