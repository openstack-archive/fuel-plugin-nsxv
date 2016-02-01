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
VMware Tools installed, otherwise there will be no connectivity and security
groups functionality.


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

Starting from version 2.0.0 plugin enables Neutron load balancing functionality
and enables it in OpenStack dashboard (Horizon).

.. note::

  Load balancing functionality requires attachment of an **exclusive** or
  **distributed** router to the subnet prior to provisioning of an load
  balancer.

Create exclusive or distributed router and connect it to subnet.

.. code-block:: bash

  $ neutron router-create --router_type exclusive r1
  $ neutron router-interface-add r1 private-subnet

Create servers.

.. code-block:: bash

  $ nova boot --image <image-uuid> --flavor m1.small www1
  $ nova boot --image <image-uuid> --flavor m1.small www2

Create a load balancer.

.. code-block:: bash

  $ neutron lbaas-loadbalancer-create --name http-lb private-subnet

Create a listener.

.. code-block:: bash

  $ neutron lbaas-listener-create --loadbalancer http-lb --protocol HTTP --protocol-port 80 \
        --name http-listener

Create a pool.

.. code-block:: bash

  $ neutron lbaas-pool-create --lb-algorithm ROUND_ROBIN --listener http-listener \
        --protocol HTTP --name http-pool

Create members.

.. code-block:: bash

  $ neutron lbaas-member-create --subnet private-subnet --address <www1-ip> --protocol-port 80 http-pool
  $ neutron lbaas-member-create --subnet private-subnet --address <www2-ip> --protocol-port 80 http-pool

Create a healthmonitor and associate it with the pool.

.. code-block:: bash

  $ neutron lbaas-heathmonitor-create --delay 3 --type HTTP --max-retries 3
  --timeout 5 --pool pool1

OpenStack environment reset/deletion
------------------------------------

Fuel NSXv plugin does not provide cleanup functionality when OpenStack
environment gets reseted or deleted.  All logical switches and edge virtual
machines remain intact, it is up to operator to delete them and free resources.
