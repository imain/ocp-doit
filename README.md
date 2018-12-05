OpenShift Installer OpenStack Dev Scripts
=========================================

# Pre-requisites

- CentOS 7
- ideally on a bare metal host
- user with sudo access

# Instructions

## 1) Create local config


Create a config file based on the example and set values appropriate for your
local environment.

`$ cp config_example.sh config_${USER}.sh`

## 2) Run the scripts in order

- `CONFIG="config_user.sh" ./01_install_requirements.sh`
- `CONFIG="config_user.sh" ./02_run_all_in_one.sh`
- `CONFIG="config_user.sh" ./03_configure_undercloud.sh`
- `CONFIG="config_user.sh" ./04_ocp_repo_sync.sh`

At step 5, you can just build the installer, or you can run a script that sets
up a local docker registry helpful if you are going to be making changes to the
OpenStack machine actuator and related components.

- `CONFIG="config_user.sh" ./build_ocp_installer.sh`

Or:

- `CONFIG="config_user.sh" ./05_build_ocp_dependencies.sh`

and finally, run the OpenShift installer to do a deployment on your local
single node OpenStack deployment:

- `CONFIG="config_user.sh" ./06_install_ocp.sh`

## 3) Installer Dev Workflow

Once you have a complete working environment, you do not need to re-run all
sripts.  If you're making changes to the installer, your workflow would look
like:

- `ocp_cleanup.sh`
- `build_ocp_installer.sh`
- `06_install_ocp.sh`
