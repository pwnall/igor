# Production Deployment

The developers test deploying this product using
[Ansible](https://github.com/ansible/ansible). We do not use or support any
non-free product, such as Ansible Tower. Our playbooks use the features in
Ansible 2.0.


## Inventory Errors

The dynamic inventory code was sourced from
[Ansible's repository](https://github.com/ansible/ansible/blob/devel/contrib/inventory/openstack.py).
Please report inventory-related errors to the Ansible repository.


## Running the Playbooks

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

After bringing up OpenStack VMs, always refresh the ansible host cache.

```bash
deploy/inventory/openstack.py --list --refresh
```

Run the deployment playbook.

```bash
ansible-playbook deploy/ansible/prod.yml
```

Last, save the contents of the `deploy/keys/` directory somewhere safe.

Re-running the deployment playbook will update the application.


## Deploying in Vagrant

The easiest way to run the deployment playbook against a Vagrant VM is the
`vagrant provision` command. The command below is a good baseline for tweaking
variables.

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
    -e os_image_user=vagrant deploy/ansible/prod.yml
```


## Real TLS Certificates

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


## Managing Multiple Deployments

Defining the `os_prefix` variable on the command line is a convenient way to
quickly switch between multiple deployments of the application.

```bash
ansible-playbook -i "localhost," -e os_prefix=algtest deploy/ansible/keys.yml
ansible-playbook -i "localhost," -e os_cloud=test -e os_prefix=algtest deploy/ansible/openstack_up.yml
deploy/inventory/openstack.py --list --refresh
ansible-playbook -e os_prefix=algtest deploy/ansible/prod.yml
```


## Bare-Metal Servers

The Ansible inventory at `deploy/ansible/inventory/openstack.py` assumes an
OpenStack deployment. Bare-metal servers can be managed by writing an inventory
file and saving it as `deploy/keys/inventory` and referencing it when invoking
the deployment playlist.

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
