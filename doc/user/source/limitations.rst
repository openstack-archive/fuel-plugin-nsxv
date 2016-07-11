Limitations
===========

Vcenter cluster names must be unique within the data center
---------------------------------

vCenter inventory allows user to form hierarchy by organizing vSphere entities
into folders. Clusters by default are created on first level of hierarchy, then
they can be put into folders. Plugin supports the clusters that are located on
all levels of the hierarchy, thus cluster names must be unique.

Incompatible roles are explicitly hidden
----------------------------------------

Is is worth to mention that following roles gets disabled for OpenStack
environment with the plugin:

 * Compute
 * Ironic
 * Cinder

Compute and Ironic are incompatible, because NSX v6.x switch is available
exclusively for ESXi, so it is not possible to pass traffic inside compute node
that runs Linux and KVM. Cinder is disabled due to inability to pass LVM based
volumes via iSCSI to ESXi hosts, instead use "Cinder proxy for VMware
datastore" role.

Public floating IP range is ignored
-----------------------------------

Fuel requires that floating IP range must be within *Public* IP range.  This
requirement does not make sense with NSXv plugin, because edge nodes provide
connectivity for virtual machines, not controllers. Nevertheless floating IP
range for *Public* network must be assigned. Plugin provides it own field for
floating IP range.

.. image:: /image/floating-ip.png
   :scale: 70 %

Pay attention that Neutron L2/L3 configuration on Settings tab does not have
effect in OpenStack cluster that uses NSXv.  These settings contain settings
for GRE tunneling which does not have an effect with NSXv.

Private network is not used
---------------------------

It does not matter on which network interface you assign *Private* network
traffic, because it does not flow through controllers. Nevertheless IP range
for *Private* network must be assigned.

OpenStack environment reset/deletion
------------------------------------

Fuel NSXv plugin does not provide cleanup mechanism when OpenStack environment
gets reset or deleted.  All logical switches and edge virtual machines remain
intact, it is up to operator to delete them and free resources.

Ceph block storage is not supported
-----------------------------------

ESXi hypervisor do not have native support for mounting Ceph.

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
