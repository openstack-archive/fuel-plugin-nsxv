Known issues
============

Deployment process may fail when big amount of NSX edge nodes is specified in backup pool
-----------------------------------------------------------------------------------------

When specifying huge amount of edge nodes in *NSX backup Edge pool* setting
deployment process may fail, because Neutron NSX plugin tries to provision
specified amount of backup nodes while Neutron server waits until this
operation is finished. Default timeout for neutron-server start is about 7
minutes. If you encounter such behaviour wait until all backup edge nodes are
provisioned on vSphere side and rerun deployment process.

Change of ``admin_state_up`` does not affect actual port state
--------------------------------------------------------------

NSX plugin does not change *admin_state_up* of a port. Even if operator
executes ``neutron port-update`` command, port will remain in active state, but
will be reported as ``admin_state_up: False`` by ``neutron port-show`` command.
