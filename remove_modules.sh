#!/bin/sh
# remove all external puppet modules

PLUGIN_MOD_DIR="deployment_scripts/puppet/modules"

dir=`dirname $0`
cd "${dir}" || exit 1

cat Puppetfile | grep "^mod '" | awk -F "'" '{ print $2 }' | while read module; do
  if [ -d "${PLUGIN_MOD_DIR}/${module}" ]; then
    echo "Remove: ${PLUGIN_MOD_DIR}/${module}"
    rm -rf "${PLUGIN_MOD_DIR}/${module}"
  fi
done
rm -f 'Puppetfile.lock'
