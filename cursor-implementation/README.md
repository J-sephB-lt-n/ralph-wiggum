# cursor implementation of Ralph Wiggum

These steps assume that lima-vm is already installed.

```bash
limactl create --name ralph --vm-type=qemu --containerd=system # default is ubuntu
limactl ls

cd ralph-wiggum/cursor-implementation
cp -r agent_harness_app_template my-app-name

# optional: if you need your CA certificates in the VM ==================== #
mkdir my-app-name/.secret/ca-certificates
cp /usr/local/share/ca-certificates/* my-app-name/.secret/ca-certificates
# ========================================================================= #

limactl start ralph --mount-only ./my-app-name/:w  # only has read/write access to my-app-name/
limactl shell ralph

# start of commands run inside the VM ================================= #
sudo cp my-app-name/.secret/ca-certificates/* /usr/local/share/ca-certificates/ # only run if you copied in your CA certs earlier
sudo update-ca-certificates

bash my-app-name/.secret/environment_setup.sh

exit
# end of commands run inside the VM =================================== #

limactl stop ralph
limactl stop --force ralph
limactl delete ralph
```
