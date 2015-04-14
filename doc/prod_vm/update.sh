#!/bin/sh
# Idempotent server VM update script.

# Product name. Must be a unix username.
PRODUCT="seven"

# Git URL that allows un-authenticated pulls.
GIT_PUBLIC_URL="https://git.pwnb.us/pwnall/seven.git"

# Git URL that allows pushes, but requires authentication.
GIT_PUSH_URL="git@git.pwnb.us:pwnall/seven.git"

set -o errexit     # Stop the script on the first error.
set -o nounset     # Catch un-initialized variables.
set +o histexpand  # No history expansion, because of arcane ! treatment.

# Make sure we're running as the $PRODUCT user.
if [ "$USER" != "$PRODUCT" ] ; then
  echo "This script must be run as the $PRODUCT user"
  exit 1
fi
if [ "$HOME" != "/home/$PRODUCT" ] ; then
  echo "This script must be run with \$HOME set to /home/$PRODUCT"
  exit 1
fi

# Update all system packages.
sudo dnf update -y

# Git.
sudo dnf install -y git

# If the server repository is already checked out, update the code.
if [ -d ~/$PRODUCT ] ; then
  cd ~/$PRODUCT
  git checkout master
  git pull --ff-only "$GIT_PUBLIC_URL" master
fi

# Otherwise, check out the server repository.
if [ ! -d ~/$PRODUCT ] ; then
  cd ~
  git clone "$GIT_PUBLIC_URL" $PRODUCT
  cd ~/$PRODUCT

  # Switch the repository URL to the one that accepts pushes.
  git remote rename origin public
  git remote add origin "$GIT_PUSH_URL"
fi

# Run the individual update scripts.
cd ~/$PRODUCT/vm
if [ -f /etc/$PRODUCT/prod.keys ] ; then
  script/update-prod-keys.sh

  # Production VMs
  if [ -f /etc/$PRODUCT/web ] ; then
    script/update-web.sh
  fi
  if [ -f /etc/$PRODUCT/cast ] ; then
    script/update-cast.sh
  fi
fi
if [ ! -f /etc/$PRODUCT/prod.keys ] ; then
  # Development VMs run all the servers in the same VM.
  script/update-web.sh
  script/update-cast.sh
fi

# Land in the user's home directory.
cd ~

