Usage
=====

The easiest way to check that the plugin works as expected is to create a
network or router using the ``neutron`` command-line tool:

::

  [root@nailgun ~]# ssh node-4    # node-4 is a controller node
  root@node-4:~# . openrc
  root@node-4:~# neutron router-create r1

You can monitor the plugin actions in ``/var/log/neutron/server.log`` and see
how edges appear in the list of the ``Networking & Security -> NSX Edges``
pane in vSphere Web Client. If you see error messages, check the
:ref:`Troubleshooting <troubleshooting>` section.

VXLAN MTU considerations
------------------------

The VXLAN protocol is used for L2 logical switching across ESXi hosts. VXLAN
adds additional data to the packet. Consider increasing the MTU size on the
network equipment connected to ESXi hosts.

Consider the following calculation when settings the MTU size:

Outer IPv4 header    == 20 bytes

Outer UDP header     == 8 bytes

VXLAN header         == 8 bytes

Inner Ethernet frame == 1518 (14 bytes header, 4 bytes 802.1q header, 1500 Payload)

Summarizing all of these we get 1554 bytes. Consider increasing MTU on the
network hardware up to 1600 bytes, wich is the default MTU value when you
configure VXLAN on ESXi hosts at the *Host Preparation* step.

To configure the jumbo frame, check the recommendations from:
https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2093324

Instances usage notes
---------------------

Instances that you run in an OpenStack cluster with vCenter and NSXv must have
VMware Tools installed, otherwise there will be no connectivity and security
groups functionality.

Neutron usage notes
-------------------

The only way to createa  distributed router is to use the Neutron CLI tool:

.. code-block:: bash

  $ neutron router-create dvr --distributed True

The creation of an exclusive tenant router is not supported in the OpenStack
dashboard (Horizon). You can create an exclusive router using Neutron CLI tool:

.. code-block:: bash

  $ neutron router-create DbTierRouter-exclusive --router_type exclusive

During the creation of an external network for tenants, you must specify
a physical network (the ``--provider:physical_network`` parameter) that
will be used to carry the VM traffic into the physical network segment. 
For Neutron with the NSX plugin, this parameter must be set to MoRef ID of
the portgroup which provides connectivity with the physical network to the
NSX edge nodes.

.. code-block:: bash

  $ neutron net-create External --router:external --provider:physical_network network-222

Loadbalancer as a service support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Starting from version 2.0.0, the plugin enables the Neutron load balancing
functionality and enables it in the OpenStack dashboard. By default, the
Neutron NSX plugin is configured with LBaaSv2 support.

.. note::

  The load balancing functionality requires attachment of an **exclusive** or
  **distributed** router to the subnet prior to the provisioning of a load
  balancer.

Create an exclusive or distributed router and connect it to subnet.

.. code-block:: bash

  $ neutron router-create --router_type exclusive r1
  $ neutron router-interface-add r1 www-subnet

Create servers and permit HTTP traffic.

.. code-block:: bash

  $ nova boot --image <image-uuid> --flavor m1.small www1
  $ nova boot --image <image-uuid> --flavor m1.small www2
  $ neutron security-group-rule-create --protocol tcp --port-range-min 80 \
        --port-range-max 80 default

Create a loadbalancer, specify a name and a subnet where you want to balance
the traffic.

.. code-block:: bash

  $ neutron lbaas-loadbalancer-create --name lb-www www-subnet

Create a listener.

.. code-block:: bash

  $ neutron lbaas-listener-create --loadbalancer lb-www --protocol HTTP \
        --protocol-port 80 --name www-listener

Create a load balancer pool.

.. code-block:: bash

  $ neutron lbaas-pool-create --lb-method ROUND_ROBIN --listener www-listener \
        --protocol HTTP --name www-pool

Find out the IP addresses of your VMs and create members in pool.

.. code-block:: bash

  $ neutron lbaas-member-create --subnet www-subnet --address 172.16.10.3
  $ neutron lbaas-member-create --subnet www-subnet --address 172.16.10.4

Create a virtual IP address.

.. code-block:: bash

  $ neutron lb-vip-create --name lb_vip --subnet-id <private-subnet-id> \
        --protocol-port 80 --protocol HTTP http-pool

Allocate the floating IP and associate it with VIP.

.. code-block:: bash

  $ neutron floatingip-create <public-net> --port-id <vip-port-uuid>


Create a healthmonitor and associate it with the pool.

.. code-block:: bash

  $ neutron lbaas-heathmonitor-create --delay 3 --type HTTP --max-retries 3
        --timeout 5 --pool www-pool
