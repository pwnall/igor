# seven

Course homework submission website.

[![Build Status](https://travis-ci.org/pwnall/seven.svg?branch=master)](https://travis-ci.org/pwnall/seven)


## Prerequisites

The site requires access to a [Docker](https://github.com/docker/docker)
daemon, a very recent Ruby and a few libraries.

Docker can only be installed directly on Linux, and is now packaged natively by
every major distribution. [docker-machine](https://github.com/docker/machine)
can be used to get access to a Docker daemon on other OSes.

The recommended way
to get Ruby set up is to get [rbenv](https://github.com/sstephenson/rbenv) and
[ruby-build](https://github.com/sstephenson/ruby-build).

The recommended way to get the libraries is your system's package manager, or
[Homebrew](http://brew.sh/) on Mac OS.

### Mac OS

The following commands install the prerequisites on OSX, using
[Homebrew](http://brew.sh).

```bash
brew install docker docker-machine imagemagick libxml2 libxslt openssl \
    pkg-config postgresql
brew link --force openssl
brew install ansible --HEAD
brew install caskroom/cask/brew-cask
brew cask install osxfuse vagrant virtualbox
docker-machine create --driver virtualbox dev

# The command below shows up when you run docker-machine env dev.
eval "$(docker-machine env dev)"
```

### OpenStack

The deployment receipes include an OpenStack bring-up playbook.
[TryStack](http://trystack.openstack.org/) is a public OpenStack cluster
intended for testing, and therefore can be used to test out any playbook
changes.


## Installation

Follow the standard steps for setting up a Rails development environment.

```bash
git clone
bundle install
rake db:create db:migrate
```

Due to [a nasty crash](https://github.com/cowboyd/therubyracer/issues/317), the
embedded CoffeeScript compilation method is disabled, and the project needs
[node.js](https://nodejs.org/) installed.

```bash
sudo apt-get install -y nodejs
sudo dnf install -y nodejs npm
```

The command below runs the development server. Ctrl+C stops it.

```bash
foreman start
```

The first user registered on the system automatically receives administrative
privileges. Course specifics can be configured by selecting Setup > Course in
the left-side menu.


## Development

Seed the database to get a reasonably large data set that covers the most used
cases. Seeding will crash without access to a Docker daemon.

```bash
rake db:seed
```

The seeded database has `costan@mit.edu` set up as an admin, with the password
`mit`.

Much of the CSS running this site is in the
[pwnstyles](https://github.com/pwnall/pwnstyles_rails) Rails engine.  Follow
the steps below to change it.

1. clone the repository in a sibling directory to seven
1. look for pwnstyles in the Gemfile, un-comment the directive that has a `path:` option, and comment out the other directive (that uses a gem)
1. `bundle install` to update Gemfile.lock
1. `rake tmp:clear` to blow up the SCSS cache
1. restart your dev server

Refreshing the page should reflect any CSS changes that you make. If that
doesn't happen, touch
`app/assets/stylesheets/pwnstyles/pwnstyles_main.css.scss`

The comments at the top of the model files are automatically generated by the
[annotate_models](https://github.com/ctran/annotate_models) plugin. Re-generate
them using the following command.

```bash
bundle exec annotate
```

Updating the bundled gems requires bundler 1.9 for now. Bundler 1.10 breaks for
some reason that we don't want to look into.

```bash
gem uninstall bundler --all
gem install bundler --version '~> 1.9.9'
```

To run integration tests that require Javascript/XHR, install PhantomJS 1.9.8.
Uploading files is [broken](https://github.com/ariya/phantomjs/issues/12506) in
version 2.0. For Mac users, use the following Homebrew command.

```bash
brew install homebrew/versions/phantomjs198
```

## Production Deployment with Ansible

The playbooks require an Ansible 2.0 from
[master](https://github.com/ansible/ansible).

### Inventory Errors

The dynamic inventory code was sourced from
[Ansible's repository](https://github.com/ansible/ansible/blob/devel/contrib/inventory/openstack.py).

### Running the Playbooks

Generate TLS certificates for the Web server.

```bash
ansible-playbook -i "localhost," deploy/ansible/keys.yml
```

Copy `clouds.example.yaml` into `clouds.yaml` and insert valid OpenStack
credentials in it.

Run the VM bringup playbook.

```bash
ansible-playbook -i "localhost," -e os_cloud=test deploy/ansible/openstack_up.yml
```

Run the deployment playbook.

```bash
ansible-playbook deploy/ansible/prod.yml
```

Last, save the contents of the `deploy/keys/` directory somewhere safe.

Re-running the deployment playbook will update the application.

### Deploying in Vagrant

The easiest way to run the deployment playbook against a Vagrant VM is the
`vagrant provision` command. The command below is a good baseline for tweaking
variables.

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
    -e os_image_user=vagrant deploy/ansible/prod.yml
```

### Real TLS Certificates

Most CAs can generate TLS certificates, given a
[Certificate Signing Request (CSR)](https://en.wikipedia.org/wiki/Certificate_signing_request)
with the server's DNS name in the DN. The TLS-generating playbook can be used
to obtain the CSR.

```bash
ansible-playbook  -i "localhost," -e os_prefix=algtest \
    -e web_server_cn=algtest.csail.mit.edu deploy/ansible/keys.yml
```

The CSR will be placed in `deploy/ansible/algtest/web_server_csr.pem` and can
be submitted to a certificate authority. The certificate issued by the CA
should be saved in `deploy/ansible/algtest/web_server.cert.pem`.

Should you need to obtain TLS certificates via a different process, place the
PEM-encoded server private key in `deploy/ansible/algtest/web_server.key.pem`,
and place the PEM-encoded server certificate in
`deploy/ansible/algtest/web_server.cert.pem` (same as in the previous
paragraph).

### Managing Multiple Deployments

Defining the `os_prefix` variable on the command line is a convenient way to
quickly switch between multiple deployments of the application.

```bash
ansible-playbook -i "localhost," -e os_prefix=algtest deploy/ansible/keys.yml
ansible-playbook -i "localhost," -e os_cloud=test -e os_prefix=algtest deploy/ansible/openstack_up.yml
ansible-playbook -e os_prefix=algtest deploy/ansible/prod.yml
```

### Bare-Metal Servers

The Ansible inventory at `deploy/ansible/inventory/openstack.py` assumes an
OpenStack deployment. Bare-metal servers can be managed by writing an inventory
file in `deploy/keys/inventory` and referencing it when invoking the deployment
playlist.

```ini
[meta-system_role_algtest_master]
alg.csail.mit.edu

[meta-system_role_algtest_worker]
```

The `os_image_user` variable defines the username used to SSH into the servers.

```bash
ansible-playbook -i deploy/keys/inventory -e os_image_user=myuser \
    -e os_prefix=algtest deploy/ansible/prod.yml
```

When running the deployment playbook the first time around, the
`--ask-become-pass` flag might be necessary to set the `sudo` password. The
deployment playbook sets up password-less sudo, so this flag is not necessary
for subsequent runs.

```bash
ansible-playbook -i deploy/keys/inventory -e os_image_user=myuser \
    -e os_prefix=algtest --ask-become-pass deploy/ansible/prod.yml
```

### Temporary Fix for Docker Bug

Auto-grading is impacted by a
[Docker bug](https://github.com/docker/docker/issues/14474).

Deploy a Docker version that is known to work well.

```bash
ansible-playbook -e hax_docker=docker-1.7.1-8.gitb6416b7.fc22 \
    deploy/ansible/hax.yml
```

Deploy the most recent Docker version in a Fedora branch, and the most recent
kernel + firmware version in a different Fedora branch. This is a quick way
to test new versions of Docker and linux kernel and see if the bug disappeared.

```bash
ansible-playbook -e hax_docker_tag=f22-updates-testing-pending \
    -e hax_kernel_tag=f23 deploy/ansible/hax.yml
```
