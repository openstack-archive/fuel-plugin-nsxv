Known issues
============

Deployment process may fail when a big amount of NSX edge nodes is specified in backup pool
-------------------------------------------------------------------------------------------

When specifying a huge amount of edge nodes in the 
guilabel:`NSX backup Edge pool` setting, the deployment process may fail,
because the Neutron NSX plugin tries to provision a
specified amount of backup nodes while Neutron server waits until this
operation is finished. The default timeout for neutron-server start is about 7
minutes. If you encounter such behaviour, wait until all the backup edge nodes
are provisioned on the vSphere side and rerun the deployment process.

Changing ``admin_state_up`` does not affect actual port state
-------------------------------------------------------------

The NSX plugin does not change *admin_state_up* of a port. Even if the operator
executes the ``neutron port-update`` command, port will remain in active state,
but will be reported as ``admin_state_up: False`` by the ``neutron port-show``
command.

3 OSTF fails in configuration with Ceilometer
---------------------------------------------

Test nsxv_ceilometer marked as *Passed*.
We do not have a TestVM image due to the disabled 'nova' AZ.
So we want to see these tests with the TestVM-VMDK image only.
See `LP1592357 <https://bugs.launchpad.net/fuel-plugin-nsxv/+bug/1592357>`_.