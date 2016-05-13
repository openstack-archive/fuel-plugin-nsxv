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
