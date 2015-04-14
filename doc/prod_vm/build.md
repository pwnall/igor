# Seven Server VM Setup Instructions

This document contains step-by-step instructions for building a VM that closely
matches the Seven production environment.


1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). If you have
Linux, your package repositories have it.

2. Install sshfs from your Linux distribution's package repositories. If you
have OSX, install the two packages on the
[FUSE for OSX page](http://osxfuse.github.com/).

3. Download the
[Fedora 64-bit ISO](http://download.fedoraproject.org/pub/fedora/linux/releases/21/Fedora/x86_64/iso/Fedora-21-x86_64-DVD.iso).

4. Set up a VirtualBox VM.
    * Name: Seven Server
    * Type: Linux
    * Version: Fedora 64-bit
    * RAM: 1024Mb
    * Disk: VDI, dynamic, 8Gb

5. Change the settings (Machine > Settings in the VirtualBox menu)
    * `Storage`
        * `Controller: SATA` > check `Use Host I/O Cache`
    * `Audio` > uncheck `Enable Audio`
    * `Network` > `Adapter 1`
        * `Advanced` > `Adapter Type`: virtio-net
        * `Advanced` > `Port Forwarding`, add the following rule
            * Name: Web
            * Protocol: TCP
            * Host IP: 0.0.0.0
            * Host Port: 9200
            * Guest IP: _(leave blank)_
            * Guest Port: 80
    * `Network` > `Adapter 2`
        * Check `Enable network adapter`
        * `Attached to` > `Host-only Adapter`
        * `Name` > `vboxnet0`
        * `Advanced` > `Adapter Type`: virtio-net
    * `Ports` > `USB` > uncheck `Enable USB 2.0 (EHCI) Controller`

6. Start VM and set up the server.
    * Select the Fedora ISO downloaded earlier.
    * Start a server installation, providing default answers, except:
        * Software Selection
            * Base Environment: Minimal Install
            * Add-Ons for Selected Environment: everything should be unchecked
        * Installation Destination
            1. Double-click the hard disk (`ATA VBOX HARRDISK`)
            2. Make sure the hard disk has a checkmark next to it
            3. Click the `Done` button
            3. Partition scheme: Standard
        * Network Configuration
            * For each of the two network devices click `Configure...`
                * General: automatically connect to this network when it is
                           available
            * Hostname: `seven`
        * Root password: `seven`
        * Do not create a user

7. After the VM restarts, set up ssh and mDNS.
    * `dnf install -y openssh-server`
    * `dnf install -y avahi nss-mdns`
    * `firewall-cmd --permanent --add-service=mdns`
    * `systemctl enable avahi-daemon`
    * `systemctl start avahi-daemon`
    * `reboot`

    * Minimize the VM console

8. Check that networking works by SSH-ing into the server from your Terminal.

    ```bash
    ssh root@seven.local
    # The password is seven
    ```
