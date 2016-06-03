#!/bin/bash -e

ROOT="$(dirname $(readlink -f $0))/../../"
UBUNTU_REPO_DIR="$ROOT/repositories/ubuntu"
TMP_DIR="$(mktemp -d)"
TMP_ARCHIVE="${TMP_DIR}/deb.zip"
# REPO_PATH get from env variable

# get latest succefull nsxv neutron plugin build
find "$UBUNTU_REPO_DIR" -name "python-vmware-nsx*.deb" -delete
wget --no-check-certificate -O "$TMP_ARCHIVE" "$REPO_PATH"
unzip "$TMP_ARCHIVE" -d "$TMP_DIR"
find "$TMP_DIR" -name "*.deb" -exec mv {} "$UBUNTU_REPO_DIR" \;
rm -rf "${TMP_DIR:?}"

# check puppet manifest, 'while' need for exit if error found
find "$ROOT/deployment_scripts/puppet/modules/nsxv" -type f -name "*.pp"| while read manifest ; do
  puppet parser validate "$manifest"
done
find "$ROOT/deployment_scripts/puppet/manifests" -type f -name "*.pp" | while read manifest ; do
  puppet parser validate "$manifest"
done

# build plugin
fpb --build "$ROOT"
