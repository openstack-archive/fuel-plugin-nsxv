Usage
=====

VXLAN MTU considerations
------------------------

The VXLAN protocol is used for L2 logical switching across ESXi hosts. VXLAN
adds additional data to the packet, please consider to increase MTU size on
network equipment that is connected to ESXi hosts.

Consider following calculation when settings MTU size:

Outer IPv4 header    == 20 bytes

Outer UDP header     == 8 bytes

VXLAN header         == 8 bytes

Inner Ethernet frame == 1518 (14 bytes header, 4 bytes 802.1q header, 1500 Payload)

Summarizing all of these we get 1554 bytes.  Consider increasing MTU on network
hardware up to 1600 bytes (default MTU value when you are configuring VXLAN on
ESXi hosts during *Host Preparation* step).

Instances usage notes
---------------------

Instances that you run in OpenStack cluster with vCenter and NSXv must have
VMware tools installed, otherwise there will be no connectivity.

Security groups functionality is available only if virtual machine has VMware
Tools installed.


Neutron usage notes
-------------------

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
parameter must be set to MoRef ID of portgroup which provides connectivity to
NSX Edge nodes.

.. code-block:: bash

  $ neutron net-create External --router:external --provider:physical_network network-222
