#!/usr/bin/env python
"""Copyright 2016 Mirantis, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.

Script adds restrictions to built-in roles, so they get hidden when plugin is
enabled for environment. Get all releases in available state and list all roles
in this release. If role incompatible with NSXv then add restrictions(hide role
if NSXv in cluster:components list). If first argument for script exists, then
delete all restrictions, which NSXv component checks.
"""

import sys

from fuelclient.objects.release import Release
from fuelclient.objects.role import Role

incompatible_roles = ["compute", "ironic", "cinder", "cinder-block-device"]
restrictions = {
    u"condition": u"'network:neutron:core:nsx' in cluster:components",
    u"action": u"hide"}
role_available_state = "available"
nsx_component_name = u"network:neutron:core:nsx"
clean = True if (len(sys.argv) > 1) else False

try:
    for release in Release.get_all_data():
        if release["state"] == role_available_state:
            for role in Role.get_all(release["id"]):
                if role["name"] in incompatible_roles:
                    meta = role["meta"]
                    if "restrictions" in meta.keys():
                        for restriction in meta["restrictions"]:
                            if nsx_component_name in restriction["condition"]:
                                if len(meta["restrictions"]) == 1 and clean:
                                    del meta["restrictions"]
                                else:
                                    meta["restrictions"].remove(restriction)
                        if not clean:
                            meta["restrictions"].append(restrictions)
                    else:
                        if not clean:
                            meta["restrictions"] = [restrictions]
                    Role.update(release["id"], role["name"], role)
except Exception:
    raise
