# Setup Secure Shell on Ubuntu Server via openssh

## On the server side 
1. Check if openssh is installed on the server or not (usually default)

```bash
apt list --installed openssh-server
```
If not, install it by
```bash
sudo apt install openssh-server
```

2. Enable ssh server

Enable ssh server at boot 
```bash
sudo systemctl enable ssh
```

Enable ssh server now
```bash
sudo systemctl start ssh
```

3. (After setting up keypair from client<->server) Configure the ssh connection to passwordless

```bash
sudo vim /etc/ssh/sshd_config
```

Set:
- PasswordAuthentication --> No
- KbdInteractiveAuthentication --> No
Save and Exit

```bash
sudo systemctl reload ssh
```

## On the client side
1. Create the keypair 

```bash
ssh-keygen -t ed25519 -f ~/.ssh/keylocation
```

2. Send the public key to server

```bash
ssh-copy-id -i ~/.ssh/keylocation.pub username@address
```
It will prompt for the password in the first time 

3. Setup the ssh config files for faster ssh

```bash
vim ~/.ssh/config
```

Setup the ssh connection in config 
```bash
Host hostname
    HostName IPaddress
    User username
    IdentityFile ~/.ssh/keylocation
    IdentitiesOnly yes
```

Give permission to the file
```bash
chmod 600 ~/.ssh/config
```

4. Check fast connection

```bash
ssh hostname
```

