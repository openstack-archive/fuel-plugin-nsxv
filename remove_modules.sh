#!/bin/sh

MODULES_DIR=deployment_scripts/puppet/modules

modules=`egrep -e ^mod Puppetfile | tr -d '[:punct:]' | awk '{ print $2; }'`

# Remove upstream puppet modules
for module in $modules
do
        rm -rf "${MODULES_DIR}/${module}"
done

# Remove openstack puppet module (a fuel-library/ in-house module)
rm -rf "${MODULES_DIR}"/openstack
