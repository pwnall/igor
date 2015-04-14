#!/bin/sh
# VM setup/update bootstrap script.

# Product name. Must be a unix username.
PRODUCT="seven"
# Update script path in the user's home directory.
UPDATE_PATH="seven/vm/script/update.sh"
# Update script URL.
UPDATE_URL="https://git.pwnb.us/pwnall/seven/raw/master/doc/prod_vm/update.sh"

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.
set +o histexpand  # No history expansion, because of arcane ! treatment.

# Enable password-less sudo for the current user.
sudo sh -c "echo '$USER ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"

# Enable sudo from non-tty sessions.
# NOTE: enabling this on the user that runs the app is dangerous.
sudo sh -c "echo 'Defaults:$USER !requiretty' >> /etc/sudoers.d/$USER"

# Used by the user creation commands below.
sudo dnf install -y openssl

if [ "$USER" != "$PRODUCT" ] ; then
  # If this is not as $PRODUCT, create up the $PRODUCT user.

  if [ -f /etc/$PRODUCT/prod.keys ] ; then
    # The user's password is random in production.
    PASSWORD="$(openssl rand -hex 32)"
  fi
  if [ ! -f /etc/$PRODUCT/prod.keys ] ; then
    # The user's password is always "$PRODUCT" in development VMs.
    PASSWORD="$PRODUCT"
  fi

  if [ ! -d /home/$PRODUCT ] ; then
    sudo useradd --home-dir /home/$PRODUCT --create-home \
        --user-group --groups wheel --shell $SHELL \
        --password $(echo "$PASSWORD" | openssl passwd -1 -stdin) $PRODUCT
    sudo chmod 0755 /home/$PRODUCT
  fi

  # Set up password-less sudo for the $PRODUCT user.
  # sudo sh -c "echo '$PRODUCT ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/$PRODUCT"

  # Enable sudo from non-tty sessions.
  # NOTE: enabling this on the user that runs the app is dangerous.
  # sudo sh -c "echo 'Defaults:$PRODUCT !requiretty' >> /etc/sudoers.d/$PRODUCT"

  # Set up SSH public key access.
  sudo mkdir -p /home/$PRODUCT/.ssh
  sudo chown $PRODUCT:$PRODUCT /home/$PRODUCT/.ssh
  sudo chmod 0700 /home/$PRODUCT/.ssh
  if [ -f ~/.ssh/authorized_keys ] ; then
    sudo cp ~/.ssh/authorized_keys /home/$PRODUCT/.ssh/authorized_keys
    sudo chown $PRODUCT:$PRODUCT /home/$PRODUCT/.ssh/authorized_keys
    sudo chmod 0600 /home/$PRODUCT/.ssh/authorized_keys
  fi

  # Add /usr/local/bin to the path, because rubygems installs stuff there.
  sudo sh -c \
      'echo "export PATH=\$PATH:/usr/local/bin" > /etc/profile.d/local_path.sh'
  sudo chmod +x /etc/profile.d/local_path.sh
fi

# If the server VM repo is already checked out, run the update script in there.
if [ "$USER" = "$PRODUCT" ] ; then
  if [ -f /home/$PRODUCT/$PRODUCT/$UPDATE_PATH ] ; then
    cd /home/$PRODUCT/$PRODUCT/$(dirname "$UPDATE_PATH")
    git checkout master
    git pull --ff-only public master
    exec /home/$PRODUCT/$PRODUCT/$UPDATE_PATH
  fi
fi

# Download and run the update script.
curl -fLsS "$UPDATE_URL" | sudo -u $PRODUCT -i
