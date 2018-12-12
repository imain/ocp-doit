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
- `CONFIG="config_user.sh" ./05_build_ocp_installer.sh`

and finally, run the OpenShift installer to do a deployment on your local
single node OpenStack deployment:

- `CONFIG="config_user.sh" ./06_run_ocp.sh`

Once the installer is running and the VMs have been created, you will probably
want to expose the service VM via a floating IP so it can be reached.

- `CONFIG="config_user.sh" ./expose_ocp_api.sh`

### Customizing Deployment

You may need to provide further customization to your deployment, such as
limiting the number of master and worker nodes created to fit in your
development environment.  You can do this by generating and editing the
`install-config.yaml` file before launching the deployment.

- `CONFIG="config_user.sh" ./06_run_ocp.sh create install-config`
- `${EDITOR} ocp/install-config.yaml
- `CONFIG="config_user.sh" ./06_run_ocp.sh`

## 3) Installer Dev Workflow

Once you have a complete working environment, you do not need to re-run all
sripts.  If you're making changes to the installer, your workflow would look
like:

- `ocp_cleanup.sh`
- `CONFIG=”config_user.sh” build_ocp_installer.sh`
- `CONFIG=”config_user.sh” 06_run_ocp.sh`
