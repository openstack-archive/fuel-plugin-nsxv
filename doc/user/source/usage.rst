Usage
=====

Easiest way to check that plugin works as expected would be trying to create
network or router using ``neutron`` command line client:

::

  [root@nailgun ~]# ssh node-4    # node-4 is a controller node
  root@node-4:~# . openrc
  root@node-4:~# neutron router-create r1

You can monitor plugin actions in ``/var/log/neutron/server.log`` and see how
edges appear in list of ``Networking & Security -> NSX Edges`` pane in vSphere
Web Client. If you see error messages check :ref:`Troubleshooting
<troubleshooting>` section.


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


The only way to create distributed router is to use neutron CLI tool:

.. code-block:: bash

  $ neutron router-create dvr --distributed True

Creation of exclusive tenant router is not supported in OpenStack dashboard
(Horizon).  You can create exclusive router using Neutron CLI tool:

.. code-block:: bash

  $ neutron router-create DbTierRouter-exclusive --router_type exclusive

During creation of external network for tenants you must specify physical
network (``--provider:physical_network`` parameter) that will be used to carry
VM traffic into physical network segment.  For Neutron with NSX plugin this
parameter must be set to MoRef ID of portgroup which provides connectivity with
physical network to NSX edge nodes.

.. code-block:: bash

  $ neutron net-create External --router:external --provider:physical_network network-222


Loadbalancer as a service support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Starting from version 2.0.0 plugin enables Neutron load balancing functionality
and enables it in OpenStack dashboard. By default Neutron NSX plugin gets
configured with LBaaSv2 support.

.. note::

  Load balancing functionality requires attachment of an **exclusive** or
  **distributed** router to the subnet prior to provisioning of an load
  balancer.

Create exclusive or distributed router and connect it to subnet.

.. code-block:: bash

  $ neutron router-create --router_type exclusive r1
  $ neutron router-interface-add r1 www-subnet

Create servers and permit HTTP traffic.

.. code-block:: bash

  $ nova boot --image <image-uuid> --flavor m1.small www1
  $ nova boot --image <image-uuid> --flavor m1.small www2
  $ neutron security-group-rule-create --protocol tcp --port-range-min 80 \
        --port-range-max 80 default

Create loadbalancer, specify name and subnet where you want to balance traffic.

.. code-block:: bash

  $ neutron lbaas-loadbalancer-create --name lb-www www-subnet

Create listener.

.. code-block:: bash

  $ neutron lbaas-listener-create --loadbalancer lb-www --protocol HTTP \
        --protocol-port 80 --name www-listener

Create a load balancer pool.

.. code-block:: bash

  $ neutron lbaas-pool-create --lb-method ROUND_ROBIN --listener www-listener \
        --protocol HTTP --name www-pool

Find out IP addresses of your VMs and create members in pool.

.. code-block:: bash

  $ neutron lbaas-member-create --subnet www-subnet --address 172.16.10.3
  $ neutron lbaas-member-create --subnet www-subnet --address 172.16.10.4

Create a virtual IP address.

.. code-block:: bash

  $ neutron lb-vip-create --name lb_vip --subnet-id <private-subnet-id> \
        --protocol-port 80 --protocol HTTP http-pool

Allocate floating IP and associate it with VIP.

.. code-block:: bash

  $ neutron floatingip-create <public-net> --port-id <vip-port-uuid>


Create a healthmonitor and associate it with the pool.

.. code-block:: bash

  $ neutron lbaas-heathmonitor-create --delay 3 --type HTTP --max-retries 3
        --timeout 5 --pool www-pool
