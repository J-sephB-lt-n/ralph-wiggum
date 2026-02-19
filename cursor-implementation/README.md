# cursor implementation of Ralph Wiggum

These steps assume that lima-vm is already installed.

```bash
limactl create --name ralph --vm-type=qemu --containerd=system # default is ubuntu
limactl ls

cd ralph-wiggum/cursor-implementation
cp -r agent_harness_app_template my-app-name
limactl start ralph --mount-only ./my-app-name/:w  # only has read/write access to my_app_name/
limactl shell ralph

limactl stop ralph
limactl stop --force ralph
limactl delete ralph
```
