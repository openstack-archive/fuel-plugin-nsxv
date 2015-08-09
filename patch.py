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


if __name__ == "__main__":
    main()
