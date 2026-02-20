# cursor implementation of Ralph Wiggum

The template for the application directory which the agents will work in is [./agent_harness_app_template/](./agent_harness_app_template/) (a copy of this directory is made, and this directory is all that the agents can see).

The application directory contains a `.secret/` folder, which all agents are instructed to ignore (in their prompts i.e. it is a soft instruction for context protection, not a guardrail).

These steps assume that lima-vm is already installed.

The model used by all agents is specified in [./agent_harness_app_template/.secret/cursor/cli-config.json]. If you wish to change this model, open cursor CLI agent and choose a new model using the `/model` command (this auto-populates your ~/.cursor/cli-config.json with the correct "model" JSON you need for that model).

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

bash my-app-name/.secret/environment_setup.sh # setup environment (install packages etc.)

cd my-app-name
sudo mv .secret/cursor/cli-config.json ~/.cursor  # global agent configuration
uv python install 3.14
uv init

exit
# end of commands run inside the VM =================================== #

limactl stop ralph
limactl stop --force ralph
limactl delete ralph
```
