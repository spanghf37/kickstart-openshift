# On-prem Single Node OpenShift without Assisted Installer

Special thanks to Ben Schmaus and [his amazing blog post](https://schmaustech.blogspot.com/2021/09/deploy-disconnected-single-node.html).

We also discussed the process here [during the Ask an OpenShift Admin live stream](https://youtu.be/eh9E1gelZew?t=2268) on Oct 20th.

1. Pre-reqs
   
   Download the tools we'll need.
   
   ```bash
   # the latest OpenShift 4.9 CLI binaries
   wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.9/openshift-client-linux.tar.gz
   wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.9/openshift-install-linux.tar.gz

   # unpackage them, optionally move to the path, clean up
   tar xzf openshift-client-linux.tar.gz
   tar xzf openshift-install-linux.tar.gz
   
   chmod 755 kubectl oc openshift-install
   sudo mv kubectl oc openshift-install /usr/local/bin/

   rm *.gz README.md

   # get the coreos-installer binary
   wget https://mirror.openshift.com/pub/openshift-v4/clients/coreos-installer/latest/coreos-installer
   chmod 755 coreos-installer
   sudo mv coreos-installer /usr/local/bin

   # get the RHCOS live ISO
   wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.9/latest/rhcos-live.x86_64.iso
   ```
   
   A DHCP reservation needs to be created for the node _or_ a static IP needs to be configured.

   Additionally, we will need four DNS records all pointing to the IP used for the node:
   
   ```
   {node-name}.domain.name
   api.clustername.domain.name
   api-int.clustername.domain.name
   *.apps.clustername.domain.name
   ```

1. Create an `install-config.yaml`
   
   Review each field, particularly `networking.machineNetwork.cidr` and `BootstrapInPlace.InstallationDisk` for your environment.

   ```bash
   cat << EOF > install-config.yaml
   apiVersion: v1
   baseDomain: work.lan
   metadata:
     name: sno
   networking:
     networkType: OVNKubernetes
     machineNetwork:
     - cidr: 192.168.14.0/24
   compute:
   - name: worker
     replicas: 0
   controlPlane:
     name: master
     replicas: 1
   platform:
     none: {}
   bootstrapInPlace:
     installationDisk: /dev/sda
   pullSecret: '{"auths":{"blah":{"auth":"blah"}}}'
   sshKey: |
     ssh-ed25519 keygoeshere
   ```
   
1. Create the Ignition config
   
   ```bash
   # make a copy of the install-config.yaml to use for this
   mkdir cluster && cp install-config.yaml cluster/

   # generate the ignition
   openshift-install create single-node-ignition-config --dir=cluster
   ```
   
1. Create an ISO with the Ignition embedded
   
   ```bash
   coreos-installer iso ignition embed -f -i cluster/bootstrap-in-place-for-live-iso.ign rhcos-live.x86_64.iso
   ```
   
   This step is technically optional, you can host the bootstrap on a webserver if desired and provide the location to the installer.

1. Boot the node to the ISO, install RHCOS
   
   If you're using a static IP, you can append the `ip=` parameters at the appropriate time. If you have very complex networking, you can boot to the live ISO environment and configure it using `nmcli`/`nmtui`, then install RHCOS with the `--copy-network` option. Otherwise, let it boot and install.
   
1. Wait for install to complete
   
   Once the node is booted and RHCOS installed, you can monitor it in the usual ways:
   
   * SSH using the `core` user, then monitor the `bootkube` service.
   * Use `openshift-install wait-for bootstrap-complete`.

   After a few minutes, bootstrapping will finish and the node will reboot. Monitor for progress in the normal way:
   
   ```bash
   openshift-install wait-for install-complete
   ```
   
   After bootstrap completes, you can also connect using the `oc`/`kubectl` command with the `kubeconfig` created by `openshift-install`.
