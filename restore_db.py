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
