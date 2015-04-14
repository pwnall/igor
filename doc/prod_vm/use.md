# Seven Server VM Use Instructions

This document contains step-by-step instructors for using a prebuilt VM that
matches the Seven production environment.


## Setup

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Most
Linux distributions have VirtualBox available in their package repositories.

2. Install sshfs. Many Linux distributions have it installed by default, and
most distributions have it in their package repositories. On OSX, install the
two packages on the [FUSE for OSX page](http://osxfuse.github.com/).

3. Download and decompress
   [the server VM image](http://people.csail.mit.edu/costan/seven/seven-server-vm.7z)

  * On OSX, a 7z decompression utility is needed, such as
    [Keka](http://www.kekaosx.com/)

4. Add the VM to VirtualBox. (Machine > Add in the VirtualBox menu)

5. Start the VM and wait for it to boot up.

6. Create an SSH key, if you don't have one.

    ```bash
    ssh-keygen -t rsa
    # press Enter all the way (default key type, no passphrase)
    ```

7. [Upload your SSH key to the Git hosting site](https://github.com/settings/ssh).

8. Set up public key SSH login and verify that it works.

    ```bash
    ssh-copy-id seven@seven.local
    ssh seven@seven.local
    # ssh should not ask for a password.
   ```

9. Personalize SSH, so you can make commits on the server.

    ```bash
    # ssh seven@seven.local
    git config --global user.name "Your Name"
    git config --global user.email your_name@gmail.com
    ```

10. Update the server software.

    ```bash
    # ssh seven@seven.local
    ~/seven/doc/prod_vm/update.sh
    ```

## General Use

For ease of development, the `seven` home directory on the server VM should be
mounted over SSHFS. This makes the source code available to all the local
software, such as Photoshop.

```bash
mkdir seven-vm
sshfs seven@seven.local: seven-vm
```

The Web server can be accessed at
[https://seven.local/](https://seven.local/)


### Web Server Development

The Web server repository is cloned in the `web` directory inside the `seven`
user's home directory.

When working on the web server, it is convenient to kill the daemonized server
and start a server from the command line.


    ```bash
    # ssh seven@seven.local
    sudo systemctl stop seven-web.target
    cd ~/seven/web
    foreman start
    ```
