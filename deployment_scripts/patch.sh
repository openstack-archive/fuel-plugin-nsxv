#/bin/bash -ex

CTL=$(which dockerctl)
PATCH=$(which patch)
TMPDIR=$(mktemp -d)
CONTAINER='nailgun'

cat > $TMPDIR/patch.py << 'EOF'
#!/usr/bin/env python

from nailgun.db.sqlalchemy.models import *
from nailgun.db import db
from copy import deepcopy

def clear_restriction():
    for release in db().query(Release).all():
        release.wizard_metadata = deepcopy(release.wizard_metadata)

        for value in release.wizard_metadata['Network']['manager']['values']:
            try:
                if value['data'] == 'neutron-tun' and value['restrictions'][0].keys()[0] == 'Compute.vcenter == true':
                  del value['restrictions']
            except:
                pass

        for index, vcenter_settings in enumerate(release.wizard_metadata['Compute']['vcenter']['bind']):
            try:
                if 'wizard:Network.manager' in  str(vcenter_settings):
                   release.wizard_metadata['Compute']['vcenter']['bind'][index]['wizard:Network.manager'] = 'neutron-tun'
            except:
                pass

        release.attributes_metadata = deepcopy(release.attributes_metadata)

        try:
            del release.attributes_metadata['editable']['common']['use_vcenter']['restrictions']
        except:
            pass

    db().commit()
    return 0


def main():
    return clear_restriction()


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
pushd $TMPDIR
$PATCH -p0 < cluster.patch
popd
$CTL copy $TMPDIR/cluster.py $CONTAINER:/usr/lib/python2.6/site-packages/nailgun/api/v1/validators/cluster.py
$CTL shell $CONTAINER rm -f /usr/lib/python2.6/site-packages/nailgun/api/v1/validators/cluster.pyc /usr/lib/python2.6/site-packages/nailgun/api/v1/validators/cluster.pyo

$CTL copy /tmp/patch.py $CONTAINER:/tmp/patch.py
$CTL shell $CONTAINER python /tmp/patch.py

$CTL restart $CONTAINER

rm -fr $TMPDIR
