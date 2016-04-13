#!/usr/bin/env python
"""
Script for delete roles incompatible with NSXv
Get all release in available state and list all roles in thi release
If role incompatible with NSXv then add restrictions(hide role if NSXv in cluster:components list)
If first argument for script exists, then delete all restrictions, which check NSXV component.
"""

import sys
from fuelclient.objects.release import Release
from fuelclient.objects.role import Role

incompatible_roles = ["compute", "ironic", "cinder", "cinder-block-device"]
restrictions = {u"condition": u"'network:neutron:core:nsx' in cluster:components", u"action": u"hide"}
role_available_state = "available"
nsx_component_name = u"network:neutron:core:nsx"
clean_restrictions = True if (len(sys.argv) > 1) else False

try:
    for release in Release.get_all_data():
        if release["state"] == role_available_state:
            for role in Role.get_all(release["id"]):
                if role["name"] in incompatible_roles:
                    meta = role["meta"]
                    if "restrictions" in meta.keys():
                        for restriction in meta["restrictions"]:
                            if nsx_component_name in restriction["condition"]:
                                if len(meta["restrictions"]) == 1 and clean_restrictions:
                                  del meta["restrictions"]
                                else:
                                  meta["restrictions"].remove(restriction)
                        if not clean_restrictions:
                            meta["restrictions"].append(restrictions)
                    else:
                        if not clean_restrictions:
                            meta["restrictions"] = [restrictions]
                    Role.update(release["id"], role["name"], role)
except:
    raise
