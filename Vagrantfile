# -*- mode: ruby -*-
# vi: set ft=ruby :

# Supported values:
# fedora-24
#
# NOTE: ubuntu-xenial may be supported when it is released; wily does not have
#       the packages required to be a master (etcd server, skydns) or a worker
#       (etcd client)
OS = 'fedora-24'

# Number of worker VMs.
WORKERS = 1

Vagrant.configure(2) do |config|
  config.vm.box = {
    'ubuntu-xenial' => 'bento/ubuntu-16.04',
    'fedora-24' => 'fedora/24-cloud-base',
  }[OS]
  config.vm.box_check_update = true

  config.vm.network :private_network, type: :dhcp, nic_type: 'virtio'

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/home/vagrant/sync', disabled: true

  # NOTE: The master is the primary machine so that we can "vagrant ssh" into
  #       it without having to provide extra arguments.
  config.vm.define "master", primary: true do |master|
    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # config.vm.network "forwarded_port", guest: 80, host: 8080
  end

  1.upto WORKERS do |worker_id|
    config.vm.define "worker#{worker_id}" do |worker|
      # NOTE: The ansible provisioning block is only defined in the last
      #       worker, so it runs after all the VMs have been created.
      if worker_id == WORKERS
        worker.vm.provision :ansible do |ansible|
          ansible.playbook = "deploy/ansible/prod.yml"
          ansible.limit = "all"

          # Simulate the groups produced by the OpenStack setup.
          ansible.groups = {
            "meta-system_role_vagrant_master" => ["master"],
            "meta-system_role_vagrant_worker" =>
                (1..WORKERS).map { |i| "worker#{i}" },
          }
          ansible.extra_vars = {
            os_prefix: "vagrant",
            os_image_user: "vagrant",

            # This can be "main" for the current Docker release, "testing" for
            # the next point release, or "experimental" for the next major
            # release.
            docker_engine_branch: "main",

            # This can be "latest" for the current Docker Swarm release, or a
            # specific tag from https://hub.docker.com/r/library/swarm/
            docker_swarm_tag: "latest",
          }

          # Uncomment for Ansible role debugging.
          # ansible.verbose = "vvv"

          # Uncomment for Ansible connection debugging.
          # ansible.verbose = "vvvv"
        end
      end
    end
  end

  config.vm.provider :virtualbox do |vb, override|
    vb.memory = 2048

    # The NAT network adapter uses the Intel PRO/1000MT adapter by default.
    vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
  end

  config.vm.provider :libvirt do |domain, override|
    domain.memory = 1024
  end
end
