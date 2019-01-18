OpenShift Installer OpenStack Dev Scripts
=========================================

# Pre-requisites

- CentOS 7
- ideally on a bare metal host
- user with passwordless sudo access

# Instructions

## 1) Create local config

Create a config file based on the example and set values appropriate for your
local environment.

`$ cp config_example.sh config_${USER}.sh`

## 2) Run the scripts in order

- `export CONFIG=config_${user}.sh`
- `./01_install_requirements.sh`
- `./02_run_all_in_one.sh`
- `./03_configure_undercloud.sh`
- `./04_ocp_repo_sync.sh`
- `./05_build_ocp_installer.sh`

and finally, run the OpenShift installer to do a deployment on your local
single node OpenStack deployment:

- `./06_run_ocp.sh`

Once the installer is running and the VMs have been created, the following
script will add an `/etc/hosts` entry for the floating IP of the service VM
hosting the API load balancer.  This is required for the installer to be able
to look up the API hostname and talk to the API.

- `./expose_ocp_api.sh`

### Customizing Deployment

You may need to provide further customization to your deployment, such as
limiting the number of master and worker nodes created to fit in your
development environment.  You can do this by generating and editing the
`install-config.yaml` file before launching the deployment.

- `./06_run_ocp.sh create install-config`
- `${EDITOR} ocp/install-config.yaml
- `./06_run_ocp.sh`

## 3) Installer Dev Workflow

Once you have a complete working environment, you do not need to re-run all
sripts.  If you're making changes to the installer, your workflow would look
like:

- `ocp_cleanup.sh`
- `build_ocp_installer.sh`
- `06_run_ocp.sh`
