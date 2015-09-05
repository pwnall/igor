# seven

Course homework submission website.


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

The following [Homebrew](http://brew.sh) commands install the requirements on
OSX.

```bash
brew install docker docker-machine imagemagick pkg-config
brew install ansible --HEAD
brew install caskroom/cask/brew-cask
brew cask install vagrant virtualbox
docker-machine create --driver virtualbox dev

# The command below shows up when you run docker-machine env dev.
eval "$(docker-machine env dev)"
```


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

To run an individual spec, use the [m](https://github.com/qrush/m) gem and
reference the line number of the spec.

```bash
$ m test/example_test.rb:4
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

