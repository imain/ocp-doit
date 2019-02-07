Scripts needed to bring up CI tenant
====================================

# Build Ignition File
`/home/jtrowbri/src/coreos/container-linux-config-transpiler/bin/ct --in-file CI-DNS.yml > CI-DNS.ign`

# Boot DNS VM
`openstack server create --user-data ./CI-DNS.ign --image b9f17972-1c3c-417f-8f08-15aa31c43a32 --flavor v1-standard-1 --security-group default --security-group CI-DNS --config-drive=true --nic net-id=4e1bce4c-193b-42ea-a494-ab05aff89c1d CI-DNS`

# Assign Floating IP hardcoded in CI template as DNS server
`openstack server add floating ip CI-DNS 162.253.55.43`

# Run CI
`home/jtrowbri/go/src/github.com/openshift/ci-operator/ci-operator -template templates/cluster-launch-installer-e2e-modified.yaml -config ~/src/openshift/release/ci-operator/config/openshift/installer/openshift-installer-master.yaml -git-ref=openshift/installer@master -secret-dir=/home/jtrowbri/src/openshift/installer-e2e/cluster-profile-openstack -namespace=trown --target=cluster-launch-installer-e2e-modified`


