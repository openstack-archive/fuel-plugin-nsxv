Limitations
===========

Vcenter cluster names must be unique within the data center
-----------------------------------------------------------

vCenter inventory allows the user to form a hierarchy by organizing
vSphere entities into folders. Clusters, by default, are created on the
first level of hierarchy, then the clusters can be put into folders.
The plugin supports the clusters that are located on
all levels of the hierarchy, thus cluster names must be unique.

Incompatible roles are explicitly hidden
----------------------------------------

The following roles are disabled for an OpenStack environment with the plugin:

 * Compute
 * Ironic
 * Cinder

Compute and Ironic are incompatible, because an NSX v6.x switch is available
exclusively for ESXi; it is not possible to pass the traffic inside a compute node
that runs Linux and KVM. Cinder is disabled due to inability to pass LVM based
volumes via iSCSI to ESXi hosts; instead, use the *Cinder proxy for VMware
datastore* role.

Public floating IP range is ignored
-----------------------------------

Fuel requires that the floating IP range must be within the *Public* IP range.
This requirement does not make sense with the NSXv plugin, because edge nodes
provide connectivity for virtual machines, not controllers. Nevertheless,
the floating IP range for the *Public* network must be assigned. The plugin
provides its own field for the floating IP range.

.. image:: /image/floating-ip.png
   :scale: 70 %

Pay attention to that the Neutron L2/L3 configuration on the
guilabel:`Settings` tab does not have an effect in the OpenStack cluster
that uses NSXv. These settings contain the settings
for GRE tunneling which does not have an effect with NSXv.

Private network is not used
---------------------------

It does not matter on which network interface you assign the *Private* network
traffic, because it does not flow through controllers. Nevertheless, an IP range
for the *Private* network must be assigned.

OpenStack environment reset/deletion
------------------------------------

The Fuel NSXv plugin does not provide a cleanup mechanism when an OpenStack
environment is reset or deleted. All logical switches and the edge virtual
machines remain intact, it is up to the operator to delete them and free
resources.

Ceph block storage is not supported
-----------------------------------

ESXi hypervisor does not have native support for mounting Ceph.

Sahara support
--------------

Sahara is not supported.

Murano support
--------------

Murano is not supported.

Ironic support
--------------

Ironic is not supported.

Ceilometer support
------------------

Ceilometer is not supported.
