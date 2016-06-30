Known issues
============

Simultaneous start of neutron-servers cause an exception
--------------------------------------------------------

When deployment scenario considers several controllers neutron-server might
fail to start.

Neutron-server manual restart can be considered as workaround for this issue.

For more information see `LP1587814
<https://bugs.launchpad.net/fuel-plugin-nsxv/+bug/1587814>`_.

Change of ``admin_state_up`` does not affect actual port state
--------------------------------------------------------------

NSX plugin does not change *admin_state_up* of a port. Even if operator
executes ``neutron port-update`` command, port will remain in active state, but
will be reported as ``admin_state_up: False`` by ``neutron port-show`` command.
