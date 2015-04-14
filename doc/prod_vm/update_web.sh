#!/bin/sh
# Idempotent Web server VM setup steps.

set -o errexit     # Stop the script on the first error.
set -o nounset     # Catch un-initialized variables.
set +o histexpand  # No history expansion, because of arcane ! treatment.

# nginx.
sudo dnf install -y nginx
sudo systemctl enable nginx

# nginx configuration for the Web server.
if [ -f /etc/seven/prod.keys ] ; then
  sudo cp ~/seven/doc/prod_vm/seven-web.conf /etc/nginx/conf.d
fi
if [ ! -f /etc/seven/prod.keys ] ; then
  sudo cp ~/seven/vm/nginx/seven-web.conf /etc/nginx/conf.d
fi
sudo chown root:root /etc/nginx/conf.d/seven-web.conf

# Get SELinux out of the way.
#sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
#sudo /usr/sbin/setenforce 0

# Load the new configuration into nginx.
sudo systemctl stop nginx
sudo systemctl start nginx


# MySQL.
sudo dnf install mariadb-server mariadb-devel
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Postgres.
cd /
sudo dnf install -y postgresql postgresql-server postgresql-devel
if sudo postgresql-setup initdb; then
  sudo systemctl enable postgresql
  sudo systemctl start postgresql
  sudo -u postgres createuser --superuser $USER
  # Don't attempt to re-create the user's database if the user already exists.
  createdb $USER
fi
cd ~

# SQLite, because Rails is uncomfortable without it.
sudo dnf install -y sqlite sqlite-devel

# Programs needed to compile gems.
sudo dnf install -y gcc gcc-c++ make automake autoconf curl-devel \
    openssl-devel zlib-devel patch

# Libraries used by nokogiri.
sudo dnf install -y libxml2-devel libxslt-devel

# Library used by rmagick.
sudo dnf install -y ImageMagick-devel ImageMagick

# node.js provides CoffeeScript compilation, because therubyracer crashes.
sudo dnf install -y nodejs npm

# Ruby and Rubygems, used by the Web server, which is written in Rails.
sudo dnf install -y ruby ruby-devel

# Bundler, used to install all the gems in a Gemfile.
sudo gem install bundler

# Foreman sets up a system service to run the server as a daemon.
sudo gem install foreman

# Rake runs the commands in the server's Rakefile.
sudo gem install rake

# For some reason, paths are messed up while updating scripts run.
GEM_BINDIR="$(sudo ruby -e 'print Gem.bindir')"

# Set up / update the Web server.
cd ~/seven/web
"$GEM_BINDIR/bundle" install
rake db:create || echo -n 'Ignore the error above during updates'
rake db:migrate db:seed

# Setup the Web server daemon.
cd ~/seven/web
if [ -f /etc/seven/prod.keys ] ; then
  "$GEM_BINDIR/rake" assets:precompile
  sudo "$GEM_BINDIR/foreman" export systemd /usr/lib/systemd/system \
      --app=seven-web \
      --procfile=Procfile --env=config/production.env --user=$USER \
      --port=9000
fi
if [ ! -f /etc/seven/prod.keys ] ; then
  sudo "$GEM_BINDIR/foreman" export systemd /usr/lib/systemd/system \
      --app=seven-web \
      --procfile=Procfile --env=.env --user=$USER --port=9000
fi
sudo systemctl enable seven-web.target
sudo systemctl stop seven-web.target
sudo systemctl start seven-web.target
