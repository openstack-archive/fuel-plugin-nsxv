Usage
=====

Instances that you run in OpenStack cluster with vCenter and NSXv must have
VMware tools installed, otherwise there will be no connectivity.

The only way to create Distributed Router is to use neutron CLI tool:

.. code-block:: bash

  $ neutron router-create dvr --distributed True

Creation of exclusive tenant router is not supported in OpenStack dashboard
(Horizon).  You can create exclusive router using Neutron CLI tool:

.. code-block:: bash

  $ neutron router-create DbTierRouter-exclusive --router_type exclusive

During creation of external network for tenants you must specify physical
network (``--provider:physical_network`` parameter) that will be used to carry
VM traffic into physical network segment.  For Neutron with NSX plugin this
paramater must be set to MoRef ID of portgroup which provides connectivity to
NSX Edge nodes.

.. code-block:: bash

  $ neutron net-create External --router:external --provider:physical_network network-222

Security groups functionality is available only if virtual machine has VMware
Tools installed.
