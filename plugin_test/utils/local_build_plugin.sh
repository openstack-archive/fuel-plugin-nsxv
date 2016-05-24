#!/bin/bash -e

ROOT="$(dirname $(readlink -f $0))/../../"
UBUNTU_REPO_DIR="$ROOT/repositories/ubuntu"
TMP_DIR="$(mktemp -d)"
TMP_ARCHIVE="${TMP_DIR}/deb.zip"
# REPO_PATH get from env variable

# get latest succefull nsxv neutron plugin build
wget --no-check-certificate -qO "$TMP_ARCHIVE" "$REPO_PATH"
unzip "$TMP_ARCHIVE" -d "$TMP_DIR"
find "$TMP_DIR" -name "*.deb" -exec mv {} "$UBUNTU_REPO_DIR" \;
rm -rf "${TMP_DIR:?}"

# check puppet manifest
find "$ROOT/deployment_scripts/puppet/modules" -type f -name *.pp -exec puppet parser validate {}  \;

# build plugin
fpb --build "$ROOT"
