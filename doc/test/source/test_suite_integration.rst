Integration
===========

TC-031: Deploy HA cluster with Fuel NSXv plugin.
-------------------------------------------------

**ID**

nsxv_ha_mode

**Description**
::

 Installation in HA mode with 3 controllers.

**Complexity**

core

**Requre to automate**

No

**Steps**
::

 Create a new environment using the Fuel UI Wizard.
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
  network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: all by default
 In Settings tab:
 enable NSXv plugin
 Add nodes:
 3 controller
 Interfaces on slaves should be setup this way in Fuel interface:
 eth0 - admin(PXE)
 eth1 - public
 eth2 - management
 eth3 - VM(Fixed) ID:103
 eth4 – storage
 Networks tab:
 Public network: start '172.16.0.2' end '172.16.0.126'
 CIDR '172.16.0.0/24'
 Gateway 172.16.0.1
 Floating ip range start '172.16.0.130' end '172.16.0.254'
 Storage: CIDR '192.168.1.0/24'
 Vlan tag is not set-Managment: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default
 Verify networks.
 Fill vcenter credentials:
 Availability zone: vcenter
 vCenter host: '172.16.0.254'
 vCenter username: <login>
 vCenter password: <password>
 Add 2 vSphere Clusters:
 vSphere Cluster: Cluster1
 Service name: vmcluster1
 Datastore regex:.*
 vSphere Cluster: Cluster2
 Service name: vmcluster2
 Datastore regex: .*
 Deploy cluster
 Run OSTF

**Expected result**

Cluster should be deployed and all OSTF test cases should be passed besides
exceptions that are described in Limitation section of Test plan.

TC-032: Deploy cluster with Fuel NSXv plugin and Ceph for Glance and Cinder.
-----------------------------------------------------------------------------

**ID**

nsxv_ceph_no_vcenter

**Description**
::

 Verifies installation of plugin with Glance and Cinder.

**Complexity**

core

**Requre to automate**

No

**Steps**
::

 Create a new environment using the Fuel UI Wizard.
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
  network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: all by default
 In Settings tab:
 enable NSXv plugin
 select 'Ceph RBD for volumes'  (Cinder)  and  'Ceph RBD for images(Glance)'
 Add nodes:
 1 controller
 1 controller + ceph-osd
 1 controller + cinder-vmware + ceph-osd
 1 cinder-vmware + ceph-osd
 Interfaces on slaves should be setup this way in Fuel interface:
 eth0 - admin(PXE)
 eth1 - public
 eth2 - management
 eth3 - VM(Fixed) ID:103
 eth4 – storage
 Networks tab:
 Public network: start '172.16.0.2' end '172.16.0.126'
 CIDR '172.16.0.0/24'
 Gateway 172.16.0.1
 Floating ip range start '172.16.0.130' end '172.16.0.254'
 Storage: CIDR '192.168.1.0/24'
 Vlan tag is not set-Management: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default
 Verify networks.
 Fill vcenter credentials:
 Availability zone: vcenter
 vCenter host: '172.16.0.254'
 vCenter username: <login>
 vCenter password: <password>

 Add 3 vSphere Clusters:
 vSphere Cluster: Cluster1
 Service name: vmcluster1
 Datastore regex:.*
 vSphere Cluster: Cluster2
 Service name: vmcluster2
 Datastore regex: .*

 Deploy cluster
 Run OSTF

**Expected result**

Cluster should be deployed and all OSTF test cases should be passed besides
exceptions that are described in Limitation section of Test plan.

TC-034: Deploy cluster with Fuel VMware NSXv plugin and ceilometer.
--------------------------------------------------------------------

**ID**

nsxv_ceilometer

**Description**
::

 Installation of plugin with ceilometer.

**Complexity**

core

**Requre to automate**

No

**Steps**
::

 Create a new environment using the Fuel UI Wizard.
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
  network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: install  ceilometer

 In Settings tab:
 enable NSXv plugin
 Add nodes:
 3 controller + mongo
 1 compute-vmware

 Interfaces on slaves should be setup this way in Fuel interface:
 eth0 - admin(PXE)
 eth1 - public
 eth2 - management
 eth3 - VM(Fixed) ID:103
 eth4 – storage

 Networks tab:
 Public network: start '172.16.0.2' end '172.16.0.126'
 CIDR '172.16.0.0/24'
 Gateway 172.16.0.1
 Floating ip range start '172.16.0.130' end '172.16.0.254'
 Storage: CIDR '192.168.1.0/24'
 Vlan tag is not set-Management: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default

 Verify networks.
 Fill vcenter credentials:
 Availability zone: vcenter
 vCenter host: '172.16.0.254'
 vCenter username: <login>
 vCenter password: <password>

 Add 1 vSphere Clusters:
 vSphere Cluster: Cluster1
 Service name: vmcluster1
 Datastore regex:.*

 Deploy cluster
 Run OSTF.

**Expected result**

Cluster should be deployed and all OSTF test cases should be passed besides
exceptions that are described in Limitation section of Test plan.

TC-035: Deploy cluster with Fuel VMware NSXv plugin, Ceph for Cinder and VMware datastore backend for Glance.
-------------------------------------------------------------------------------------------------------------

**ID**

nsxv_ceph

**Description**
::

 Verifies installation of plugin for vcenter with Glance and Cinder.

**Complexity**

core

**Requre to automate**

No

**Steps**
::

 Create a new environment using the Fuel UI Wizard.
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
  network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: default

 In Settings tab:
 enable NSXv plugin
 select 'Ceph RBD for volumes' (Cinder) and 'Vmware Datastore for images(Glance)'

 Add nodes:
 3 controller + ceph-osd
 2 cinder-vmware

 Interfaces on slaves should be setup this way in Fuel interface:
 eth0 - admin(PXE)
 eth1 - public
 eth2 - management
 eth3 - VM(Fixed) ID:103
 eth4 – storage

 Networks tab:
 Public network: start '172.16.0.2' end '172.16.0.126'
 CIDR '172.16.0.0/24'
 Gateway 172.16.0.1
 Floating ip range start '172.16.0.130' end '172.16.0.254'
 Storage: CIDR '192.168.1.0/24'
 Vlan tag is not set-Management: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default

 Verify networks.

 Fill vcenter credentials:
 Availability zone: vcenter
 vCenter host: '172.16.0.254'
 vCenter username: <login>
 vCenter password: <password>
 Add 2 vSphere Clusters:
 vSphere Cluster: Cluster1
 Service name: vmcluster1
 Datastore regex:.*
 vSphere Cluster: Cluster2
 Service name: vmcluster2
 Datastore regex: .*
 Deploy cluster
 Run OSTF

**Expected result**

Cluster should be deployed and all OSTF test cases should be passed besides
exceptions that are described in Limitation section of Test plan.
