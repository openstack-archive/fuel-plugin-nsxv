#!/bin/bash

CTL=$(which dockerctl)
PATCH=$(which patch)
TMPDIR=$(mktemp -d)
CONTAINER='nailgun'

cat > $TMPDIR/patch.py << 'EOF'
#!/usr/bin/env python

from nailgun.db.sqlalchemy.models import *
from nailgun.db import db
from copy import deepcopy

neutron_tun_restrictions=[{'Compute.vcenter == true': 'dialog.create_cluster_wizard.network.hypervisor_alert'}]
use_vcenter_restrictions=[{'condition': "cluster:net_provider == 'nova_network'"}]

def restore_restriction():
    for release in db().query(Release).all():
        release.wizard_metadata = deepcopy(release.wizard_metadata)

        for value in release.wizard_metadata['Network']['manager']['values']:
            try:
                if value['data'] == 'neutron-tun':
                  value['restrictions'] = neutron_tun_restrictions
            except:
                pass

        for index, vcenter_settings in enumerate(release.wizard_metadata['Compute']['vcenter']['bind']):
            try:
                if 'wizard:Network.manager' in  str(vcenter_settings):
                   release.wizard_metadata['Compute']['vcenter']['bind'][index]['wizard:Network.manager'] = 'nova-network'
            except:
                pass

        release.attributes_metadata = deepcopy(release.attributes_metadata)

        try:
            release.attributes_metadata['editable']['common']['use_vcenter']['restrictions'] = use_vcenter_restrictions
        except:
            pass

    db().commit()
    return 0


def main():
    return restore_restriction()


if __name__ == '__main__':
    main()
EOF

cat > $TMPDIR/cluster.patch << 'EOF'
--- cluster.py.orig  2015-09-15 14:42:26.231316542 +0000
+++ cluster.py       2015-09-15 14:42:33.647312152 +0000
@@ -224,14 +224,7 @@

     @classmethod
     def _validate_net_provider(cls, data, cluster):
-        common_attrs = data.get('editable', {}).get('common', {})
-        net_provider = cluster.net_provider
-
-        if common_attrs.get('use_vcenter', {}).get('value') is True and \
-                net_provider != consts.CLUSTER_NET_PROVIDERS.nova_network:
-                    raise errors.InvalidData(u'vCenter requires Nova Network '
-                                             'to be set as a network provider',
-                                             log_message=True)
+        return True

     @classmethod
     def validate_editable_attributes(cls, data):
EOF

$CTL copy $CONTAINER:/usr/lib/python2.6/site-packages/nailgun/api/v1/validators/cluster.py $TMPDIR/cluster.py
pushd $TMPDIR 1>/dev/null
$PATCH -p0 -N -R --dry-run --silent < cluster.patch 2>/dev/null 1>/dev/null
if [ $? -eq 0 ];
then
  $PATCH -p0 -N -R < cluster.patch

  $CTL copy $TMPDIR/cluster.py $CONTAINER:/usr/lib/python2.6/site-packages/nailgun/api/v1/validators/cluster.py
  $CTL shell $CONTAINER rm -f /usr/lib/python2.6/site-packages/nailgun/api/v1/validators/cluster.pyc /usr/lib/python2.6/site-packages/nailgun/api/v1/validators/cluster.pyo

  $CTL restart $CONTAINER

  # check all service started
  while :; do
    if [ -z "$($CTL shell $CONTAINER supervisorctl status|grep -v 'RUNNING')" ]; then break ; fi
    sleep 5
  done
fi
popd 1>/dev/null

$CTL copy $TMPDIR/patch.py $CONTAINER:/tmp/patch.py
$CTL shell $CONTAINER python /tmp/patch.py 1>/dev/null

rm -fr $TMPDIR
