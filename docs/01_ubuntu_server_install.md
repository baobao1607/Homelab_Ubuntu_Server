# Installing Ubuntu Server 26.04.1 LTS

**The server is installed with UEFI dual booting on a Dell Inspiron with the following hardware specs:**
    - RAM: 32GB
    - Storage: 512GB
    - CPU: AMD Ryzen 5 3500U with Radeon Vega Mobile Gfx
    - drive needed: None

## Downloading Ubuntu ISO from official Ubuntu website

Download the ISO image directly from Ubuntu website @https://ubuntu.com/download/server

## Boot from internal partition (USB-less install)

1. In Disk Management: Shrink drive C by the amount of GB to cover for Ubuntu ISO installer + Ubuntu storage
2. Created a volume for the ISO and copied the Ubuntu Server USO contents into it.
3. Use diskpart and change that volume into EFI System Partition
4. Suspend BitLocker on all drives --> firmware can read the installer partition (D:)
5. Boot into BIOS (Dell - Pressing F2) --> Go to Boot Tab --> Disable Secure Boot --> Apply changes
6. Boot into Boot Menu (Dell - Pressing F12) --> Boot into Ubuntu installer 

## Install Ubuntu server

1. Booted into installer, choose "Install Ubuntu Server", follow the prompts (Language, Keyboard layout, etc).
2. Set the storage as ext4 mounted at "/"
3. Disable network setup 


## Clean up

1. Turned on Secure Boot
2. Turned on Encryption on Windows

