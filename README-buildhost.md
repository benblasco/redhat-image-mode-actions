# Build host configuration using Ansible
This playbook will complete the following for you:
1. Install the `container-tools` meta-package and `git`
2. Log in to the podman registry
3. Pull the latest RHEL 9 Bootc Image Builder container image from registry.redhat.com
4. Pull this (fork of the original) repo into a directory under `/root/`
5. Create an output directory for the image build under `/root/output`

Much of this could be further parametrised, including the repo and directory selection. I'll get around to it, or I won't!

## Prerequisites

1. Ansible installed on a host to run this playbook

## Simple instructions

1. Copy group_vars/all/registry_credential.yml.EXAMPLE to group_vars/all/registry_credential.yml
2. Edit registry_credential.yml, adding your own RHN username and password to allow login to registry.redhat.io
3. Copy hosts.EXAMPLE to hosts
4. Edit hosts and populate it with your own inventory, pointing to the build host, e.g.
    ```
    [build_hosts]
    buildhost.example.com ansible_host=192.168.1.148
    ```
5. Run the playbook:
```
ansible-playbook configure-build-host.yml
```

Once this is complete the build host is ready to run your favourite Bootc Image Builder command to build a new image, e.g.

With config.toml:
```
podman run \
   --rm \
   -it \
   --privileged \
   --pull=newer \
   --security-opt label=type:unconfined_t \
   -v $(pwd)/config.toml:/config.toml:ro \
   -v $(pwd)/output:/output \
   -v /var/lib/containers/storage:/var/lib/containers/storage \
   registry.redhat.io/rhel9/bootc-image-builder:latest \
   --local \
   --type qcow2 \
   ghcr.io/benblasco/redhat-image-mode-actions:latest
```

Without config.toml:
```
podman run \
   --rm \
   -it \
   --privileged \
   --pull=newer \
   --security-opt label=type:unconfined_t \
   -v $(pwd)/output:/output \
   -v /var/lib/containers/storage:/var/lib/containers/storage \
   registry.redhat.io/rhel9/bootc-image-builder:latest \
   --local \
   --type qcow2 \
   ghcr.io/benblasco/redhat-image-mode-actions:latest
```
                                                                                                                        69,1          Bot


