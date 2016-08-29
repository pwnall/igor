# Production Deployment

The developers test deploying this product using
[Ansible](https://github.com/ansible/ansible). We do not use or support any
non-free product, such as Ansible Tower. Our playbooks use the features in
Ansible 2.1.


## Inventory Errors

The dynamic inventory code was sourced from
[Ansible's repository](https://github.com/ansible/ansible/blob/devel/contrib/inventory/openstack.py).
Please report inventory-related errors to the Ansible repository.


## Running the Playbooks

Inspect the configuration in `deploy/openstack_vars.yml`. The knobs in there
can be tweaked by writing the files, or by using the `-e` command-line argument
for `ansible-playbook`.

Generate TLS certificates for the Docker Swarm cluster and Web server. Err on
the side of making `worker_count` larger, because it never hurts to have a
surplus of worker keys  lying around, as they can be used to spin up new
workers quickly.

```bash
ansible-playbook -i "localhost," -e worker_count=10 \
    -e app_certs_domain=igor.myschool.edu -e app_certs_email=admin@igor.dev \
    deploy/ansible/keys.yml
```

`app_certs_domain` must be a DNS address that you can point to the IP of the
master computer in the deployment. Deployments where using a DNS domain is
not appropriate can substitute a fake Web TLS certificate for the
[Let's Encrypt](https://letsencrypt.org/) certificate.

```bash
ansible-playbook -i "localhost," -e worker_count=10 -e use_certbot=no \
    deploy/ansible/keys.yml
```

Copy `clouds.example.yaml` into `clouds.yaml` and insert valid OpenStack
credentials in it.

Run the VM bringup playbook. It is safe to change `worker_count` here in order
to get more workers up, as long as there are enough keys lying around.

```bash
ansible-playbook -i "localhost," -e os_cloud=test deploy/ansible/openstack_up.yml
```

After bringing up OpenStack VMs, always refresh the ansible host cache.

```bash
deploy/ansible/inventory/openstack.py --list --refresh
```

If applicable, configure the DNS server to point the record referenced by
`app_certs_domain` to the master's IP address.

Run the deployment playbook.

```bash
ansible-playbook deploy/ansible/prod.yml
```

Last, save the contents of the `deploy/keys/` directory somewhere safe.

Re-running the deployment playbook will update the application.


## Manual Deployment in Vagrant

The easiest way to run the deployment playbook against a Vagrant VM is the
`vagrant provision` command. The command below is a good baseline for tweaking
variables.

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
    -e os_image_user=vagrant deploy/ansible/prod.yml
```


## Managing Multiple Deployments

Defining the `os_prefix` variable on the command line is a convenient way to
quickly switch between multiple deployments of the application.

```bash
ansible-playbook -i "localhost," -e os_prefix=igortest -e worker_count=10 \
    -e app_certs_domain=igor.myschool.edu -e app_certs_email=admin@igor.dev \
    deploy/ansible/keys.yml
ansible-playbook -i "localhost," -e os_prefix=igortest -e worker_count=10 \
    -e use_certbot=no deploy/ansible/keys.yml
ansible-playbook -i "localhost," -e os_cloud=test -e os_prefix=igortest \
    deploy/ansible/openstack_up.yml
deploy/ansible/inventory/openstack.py --list --refresh    
ansible-playbook -e os_prefix=igortest deploy/ansible/prod.yml
```


## Bare-Metal Servers

The Ansible inventory at `deploy/ansible/inventory/openstack.py` assumes an
OpenStack deployment. Bare-metal servers can be managed by writing an inventory
file and saving it as `deploy/keys/igortest/inventory` and referencing it when
invoking the deployment playlist.

```ini
[meta-system_role_igortest_master]
igortest-master ansible_host=igor-master.mit.edu

[meta-system_role_igortest_worker]
igortest-worker1 ansible_host=igor-worker1.mit.edu cluster_net_interface=eno1
```

The `os_image_user` variable defines the username used to SSH into the servers.

```bash
ansible-playbook -i deploy/keys/igortest/inventory -e os_image_user=myuser \
    -e os_prefix=igortest deploy/ansible/prod.yml
```

When running the deployment playbook the first time around, the
`--ask-become-pass` flag might be necessary to set the `sudo` password. The
deployment playbook sets up password-less sudo, so this flag is not necessary
for subsequent runs.

```bash
ansible-playbook -i deploy/keys/inventory -e os_image_user=myuser \
    -e os_prefix=igortest --ask-become-pass deploy/ansible/prod.yml
```
