Smoke tests
===========

TC-001: Verify that Fuel VMware NSX-v plugin is installed.
----------------------------------------------------------

**ID**

nsxv_plugin

**Description**
::

 Test case verifies plugin installation.

**Complexity**

smoke

**Requre to automate**

Yes

**Steps**
::

 Copy plugin to to the Fuel master node using scp.
 Install plugin
 fuel plugins --install plugin-name-1.0-0.0.1-0.noarch.rpm
 Ensure that plugin is installed successfully using cli, run command 'fuel plugins list'.
 Connect to the Fuel web UI.
 Create a new environment using the Fuel UI Wizard:
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and Qemu radio button
 network setup : Neutron with tunnel segmentation
 storage backends: default
 additional services: all by default
 Click on the Settings tab and check that section of  NSX-v  plugin is displayed with all required GUI elements.Section of  NSX-v plugin is displayed with all required GUI elements.

TC-002: Verify that Fuel VMware NSX-v plugin  is uninstalled.
-------------------------------------------------------------

**ID**

nsxv_plugin

**Description**
::

 Test verifies that plugin could be uninstalled.

**Complexity**

smoke

**Requre to automate**

Yes

**Steps**
::

 Remove plugin from master node
 fuel plugins --remove plugin-name==1.0.0
 Verify that plugin is removed, run command 'fuel plugins'.
 Connect to the Fuel web UI.
 Create a new environment using the Fuel UI Wizard:
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and Qemu radio button
 network setup : Neutron with tunnel segmentation.
 storage backhands: default
 additional services: all by default

 Click on the Settings tab and check that section of  NSX-v  plugin is not displayedSection of  NSX-v  plugin is not displayed.

TC-003: Deploy cluster with plugin and vmware datastore backend.
----------------------------------------------------------------

**ID**

nsxv_smoke

**Description**
::

 Test verifies installation with base configuration.

**Complexity**

smoke

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
 enable NSX-v plugin
 select Vmware vcenter esxi datastore for images (glance)
 Add nodes:
 1 controller
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

 Add 2 vSphere Clusters:
 vSphere Cluster: Cluster1
 Service name: vmcluster1
 Datastore regex:.*
 vSphere Cluster: Cluster2
 Service name: vmcluster2
 Datastore regex: .*

 Fill Glance credentials:
 vCenter host: 172.16.0.254
 vCenter username: <login>
 vCenter password: <password>
 Datacenter name: Datacenter
 Datastore name: nfs

 Deploy cluster

 Run OSTF
 Cluster should be deployed and all OSTF test cases should be passed.

Integration tests
=================

TC-031: Deploy HA cluster with Fuel NSX-v plugin.
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
 enable NSX-v plugin
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
 Run OSTFCluster should be deployed and all OSTF test cases should be passed.

TC-032: Deploy cluster with Fuel NSX-v plugin and Ceph for Glance and Cinder.
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
 enable NSX-v plugin
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
 Run OSTFCluster should be deployed and all OSTF test cases should be passed.

TC-034: Deploy cluster with Fuel VMware NSX-v plugin and ceilometer.
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
 enable NSX-v plugin
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
 Run OSTFCluster should be deployed and all OSTF test cases should be passed.

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
 enable NSX-v plugin
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

System tests
============

Setup for system tests
----------------------

**ID**

TO DO

**Description**
::

 It is a config for all system tests.

**Complexity**

advanced

**Requre to automate**

Yes

**Steps**
::

 Install NSX-v plugin on master node.
 Launch instances from tcl.vmdk image which is included in plugin package and is available under Horizon. Use m1.tiny size or m1.micro128.
 Create a new environment using the Fuel UI Wizard.
 add name of an env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
 network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: all by default

 In Settings tab:
 enable NSX-v plugin
 Add nodes:
 3 controller
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
 Add 2 vSphere Clusters:
 vSphere Cluster: Cluster1
 Service name: vmcluster1
 Datastore regex:.*
 vSphere Cluster: Cluster2
 Service name: vmcluster2
 Datastore regex: .*

 Deploy cluster

 Run OSTF
 Cluster should be deployed and all OSTF test cases should be passed.

TC-061: Check abilities to create and terminate networks on NSX.
----------------------------------------------------------------

**ID**

nsxv_create_terminate_networks

**Description**
::

 Verifies that creation of network is translated to vcenter.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.

 Add private networks net_01 and net_02.

 Check that networks are present in the vSphere.

 Remove private network net_01.

 Check that network net_01 is not present in the vSphere.
 Add private network net_01.

 Check that networks is  present in the vSphere.Networks  net_01 and  net_02 should be added.

TC-062: Check abilities to assign multiple vNIC to a single VM.
---------------------------------------------------------------

**ID**

nsxv_assign_multiple_vnic

**Description**
::

 It is possible to assign multiple vNICs.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.
 Add two private networks (net01, and net02).
 Add one  subnet (net01_subnet01: 192.168.101.0/24, net02_subnet01, 192.168.102.0/24) to each network.
 Launch instance VM_1 with image TestVM-VMDK and flavor m1.tiny in vcenter1 az.
 Launch instance VM_2  with image TestVM-VMDK and flavor m1.tiny vcenter2 az.
 Check abilities to assign multiple vNIC net01 and net02 to VM_1 .

 Check abilities to assign multiple vNIC net01 and net02 to VM_2.
 Send icmp ping from VM _1 to VM_2  and vice versa.VM_1 and VM_2 should be attached to multiple vNIC net01 and net02.  Pings should get a response.

TC-063: Check connection between VMs in one tenant.
---------------------------------------------------

**ID**

TO DO

**Description**
::

 Checks connections between VMs inside a tenant.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.

 Navigate to Project ->  Compute -> Instances

 Launch instance VM_1 with image TestVM-VMDK and flavor m1.tiny in vcenter1 az.

 Launch instance VM_2 with image TestVM-VMDK and flavor m1.tiny in vcenter2 az.

 Verify that VMs on same tenants should communicate between each other. Send icmp ping from VM _1 to VM_2  and vice versa.
 Pings should get a response

TC-064: Check connectivity between VMs attached to different networks with a router between them.
-------------------------------------------------------------------------------------------------

**ID**

nsxv_connectivity_between_different_networks

**Description**
::

 Verifies that there is a connection between networks connected through the router.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.

 Add two private networks (net01, and net02).

 Add one  subnet (net01_subnet01: 192.168.101.0/24, net02_subnet01, 192.168.102.0/24) to each network.

 Navigate to Project ->  Compute -> Instances

 Launch instances VM_1 and VM_2 in the network192.168.101.0/24 with image TestVM-VMDK and flavor m1.tiny in vcenter1 az.

 Launch instances VM_3 and VM_4 in the 192.168.102.0/24 with image TestVM-VMDK and flavor m1.tiny in vcenter2 az.

 Verify that VMs of same networks should communicate
 between each other. Send icmp ping from VM 1 to VM2, VM 3 to VM4 and vice versa.
 Verify that VMs of different networks should not communicate
 between each other. Send icmp ping from VM 1 to VM3, VM_4 to VM_2 and vice versa.
 Create Router_01, set gateway and add interface to external network.
 Attach private networks to router.

 Verify that VMs of different networks should communicate between each other. Send icmp ping from VM 1 to VM3, VM_4 to VM_2 and vice versa.
 Add new Router_02, set gateway and add interface to external network.
 Detach net_02 from Router_01 and attach to Router_02

 Verify that VMs of different networks should communicate between each other. Send icmp ping from VM 1 to VM3, VM_4 to VM_2 and vice versa
 Pings should get a response.

TC-065: Check connectivity between VMs attached on the same provider network with shared router.
------------------------------------------------------------------------------------------------

**ID**

nsxv_connectivity_via_shared_router

**Description**
::

 Checks that it is possible to connect via shared router type.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Add provider network via cli.

 Log in to Horizon Dashboard.
 Create shared router(default type) and use it for routing between instances.
 Navigate to Project ->  compute -> Instances
 Launch instance VM_1 in the provider network with image TestVM-VMDK and flavor m1.tiny in the vcenter1 az.

 Launch instance VM_2  in the provider network  with image TestVM-VMDK and flavor m1.tiny in the vcenter2 az.

 Verify that VMs of  same provider network should communicate
 between each other. Send icmp ping from VM _1 to VM_2  and vice versa.
 Pings should get a response.

TC-066: Check connectivity between VMs attached on the same provider network with distributed router.
-----------------------------------------------------------------------------------------------------

**ID**

nsxv_connectivity_via_distributed_router

**Description**
::

 Verifies that there is possibility to connect via distributed router type.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Add provider network via cli.

 Log in to Horizon Dashboard.

 Create distributed router and use it for routing between instances. Only available via CLI:
 neutron router-create rdistributed --distributed True

 Navigate to Project ->  compute -> Instances
 Launch instance VM_1 in the provider network with image TestVM-VMDK and flavor m1.tiny in the vcenter1 az.

 Launch instance VM_2  in the provider network  with image TestVM-VMDK and flavor m1.tiny in the vcenter2 az.

 Verify that VMs of  same provider network should communicate
 between each other. Send icmp ping from VM _1 to VM_2  and vice versa.
 Pings should get a response.

TC-067: Check connectivity between VMs attached on the same provider network with exclusive router.
---------------------------------------------------------------------------------------------------

**ID**

nsxv_connectivity_via_exclusive_router

**Description**
::

 Verifies that there is possibility to connect via exclusive router type.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Add provider network via cli.

 Log in to Horizon Dashboard.

 Create exclusive router and use it for routing between instances. Only available via CLI:
 neutron router-create rexclusive --router_type exclusive

 Navigate to Project ->  compute -> Instances
 Launch instance VM_1 in the provider network with image TestVMDK-TCL and flavor m1.tiny in the vcenter1 az.

 Launch instance VM_2  in the provider network  with image TestVMDK-TCL and flavor m1.tiny in the vcenter2 az.

 Verify that VMs of  same provider network should communicate
 between each other. Send icmp ping from VM _1 to VM_2  and vice versa. Pings should get a response.

TC-068: Check isolation between VMs in different tenants.
---------------------------------------------------------

**ID**

nsxv_different_tenants

**Description**
::

 Verifies isolation in different tenants.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.
 Create non-admin tenant test_tenant.

 Navigate to Identity -> Projects.

 Click on Create Project.
 Type name test_tenant.

 On tab Project Members add admin with admin and member

 Navigate to Project -> Network -> Networks

 Create network  with 2 subnet
 Navigate to Project ->  compute -> Instances
 Launch instance VM_1
 Navigate to test_tenant

 Navigate to Project -> Network -> Networks

 Create network  with subnet.
 Create Router, set gateway and add interface

 Navigate to Project ->  compute -> Instances

 Launch instance VM_2

 Verify that VMs on different tenants should not communicate
 between each other. Send icmp ping from VM _1 of admin tenant to VM_2  of test_tenant and vice versa.Pings should not get a response.

TC-069: Check connectivity between VMs with same ip in different tenants.
-------------------------------------------------------------------------

**ID**

nsxv_same_ip_different_tenants

**Description**
::

 Verifies connectivity with same IP in different tenants.

**Complexity**

advanced

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.

 Create 2 non-admin tenants ‘test_1’ and ‘test_2’.
 Navigate to Identity -> Projects.
 Click on Create Project.

 Type name ‘test_1’ of tenant.

 Click on Create Project.

 Type name ‘test_2’ of tenant.

 On tab Project Members add admin with admin and member.

 In tenant ‘test_1’  create net1 and subnet1 with CIDR 10.0.0.0/24
 In tenant ‘test_1’  create security group ‘SG_1’ and add rule that allows ingress icmp traffic
 In tenant ‘test_2’  create net2 and subnet2 with CIDR 10.0.0.0/24
 In tenant ‘test_2’ create security group ‘SG_2’

 In tenant ‘test_1’  add  VM_1 of vcenter1  in net1 with ip 10.0.0.4 and  ‘SG_1’ as security group.
 In tenant ‘test_1’  add  VM_2 of vcenter2 in net1 with ip 10.0.0.5 and  ‘SG_1’ as security group.
 In tenant ‘test_2’  create net1 and subnet1 with CIDR 10.0.0.0/24
 n tenant ‘test_2’  create security group ‘SG_1’ and add rule that allows ingress icmp traffic
 In tenant ‘test_2’  add  VM_3 of vcenter1  in net1 with ip 10.0.0.4 and  ‘SG_1’ as security group.
 In tenant ‘test_2’  add  VM_4 of  vcenter2 in net1 with ip 10.0.0.5 and  ‘SG_1’ as security group.
 Verify that VMs with same ip on different tenants should communicate
 between each other. Send icmp ping from VM _1 to VM_3,  VM_2 to Vm_4 and vice versa.Pings should  get a response.

TC-070: Check connectivity Vms to public network.
-------------------------------------------------

**ID**

nsxv_public_network_availability

**Description**
::

 Verifies that public network is available.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.

 Create net01: net01_subnet, 192.168.112.0/24 and attach it to the router04
 Launch instance VM_1 of vcenter1 AZ with image TestVM-VMDK and flavor m1.tiny in the net_04.
 Launch instance VM_1 of vcenter2 AZ with image TestVM-VMDK and flavor m1.tiny in the net_01.
 Send ping from instances VM_1 and VM_2 to 8.8.8.8 or other outside ip. Pings should  get a response

TC-071: Check connectivity Vms to public network with floating ip.
------------------------------------------------------------------

**ID**

nsxv_floating_ip_to_public

**Description**
::

 Verifies that public network is available via floating ip.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard
 Create net01: net01_subnet, 192.168.112.0/24 and attach it to the router04
 Launch instance VM_1 of vcenter1 AZ with image TestVM-VMDK and flavor m1.tiny in the net_04. Associate floating ip.

 Launch instance VM_1 of vcenter2 AZ with image TestVM-VMDK and flavor m1.tiny in the net_01. Associate floating ip.

 Send ping from instances VM_1 and VM_2 to 8.8.8.8 or other outside ip. Pings should  get a response

TC-072: Check abilities to create and delete security group.
------------------------------------------------------------

**ID**

nsxv_create_and_delete_secgroups

**Description**
::

 Verifies that creation and deletion security group works fine.

**Complexity**

advanced

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.
 Launch instance VM_1 in the tenant network net_02 with image TestVM-VMDK and flavor m1.tiny in the vcenter1 az.
 Launch instance VM_2  in the tenant net_02  with image TestVM-VMDK and flavor m1.tiny in the vcenter2 az.

 Create security groups SG_1 to allow ICMP traffic.
 Add Ingress rule for ICMP protocol to SG_1

 Attach SG_1 to VMs

 Check ping between VM_1 and VM_2 and vice verse

 Create security groups SG_2 to allow TCP traffic 80 port.
 Add Ingress rule for TCP protocol to SG_2

 Attach SG_2 to VMs

 ssh from VM_1 to VM_2 and vice verse
 Delete all rules from SG_1 and SG_2

 Check ping and ssh aren’t available from VM_1 to VM_2  and vice verse
 Add Ingress rule for ICMP protocol to SG_1

 Add Ingress rule for TCP protocol to SG_2

 Check ping between VM_1 and VM_2 and vice verse

 Check ssh from VM_1 to VM_2 and vice verse
 Delete security groups.
 Attach Vms to default security group.

 Check ping between VM_1 and VM_2 and vice verse
 Check SSH from VM_1 to VM_2 and vice verse
 We should have the ability to send ICMP and TCP traffic between VMs in different tenants.

TC-073: Verify that only the associated MAC and IP addresses can communicate on the logical port.
-------------------------------------------------------------------------------------------------

**ID**

nsxv_associated_addresses_communication_on_port

**Description**
::

 Verifies that only associated addresses can communicate on the logical port.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.

 Launch 2 instances.
 Verify that traffic can be successfully sent from and received on the MAC and IP address associated with the logical port.
 Configure a new IP address on the instance associated with the logical port.
 Confirm that the instance cannot communicate with that IP address.
 Configure a new MAC address on the instance associated with the logical port.
 Confirm that the instance cannot communicate with that MAC address and the original IP address.Instance should not communicate with new ip and mac addresses but it should communicate with old IP.

TC-075: Check creation instance in the one group simultaneously.
----------------------------------------------------------------

**ID**

nsxv_create_and_delete_vms

**Description**
::

 Verifies that system could create and delete several instances simultaneously.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Navigate to Project -> Compute -> Instances
 Launch 5 instance VM_1 simultaneously with image TestVM-VMDK and flavor m1.micro in vcenter1 az in default net_04

 All instance should be created without any error.

 Launch 5 instance VM_2 simultaneously with image TestVM-VMDK and flavor m1.micro in vcenter2 az in default net_04

 All instance should be created without any error.

 Check connection between VMs (ping, ssh)

 Delete all VMs from horizon simultaneously.
 All instance should be created without any error.

TC-076: Check that environment support assigning public network to all nodes
----------------------------------------------------------------------------

**ID**

nsxv_public_network_to_all_nodes

**Description**
::

 Verifies that checkbox "Assign public network to all nodes" works as designed.

 Assuming default installation has been done with unchecked option "Assign public network to all nodes".

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Connect through ssh to Controller node.
 Run 'ifconfig'There is an interface with ip from public network IP Range (Networks tab).
 Connect through ssh to compute-vmware node.
 Run 'ifconfig'There is no interface with ip from public network IP Range.
 Redeploy environment with checked option Public network assignment -> Assign public network to all nodes.Option is checked after deploy.
 Connect through ssh to Controller node.
 Run 'ifconfig'There is an interface with ip from public network IP Range.
 Connect through ssh to compute-vmware node.
 Run 'ifconfig'There is an interface with ip from public network IP Range also.

Destructive tests
=================

TC-101: Check abilities to bind port on NSX-v to VM, disable and enable this port.
----------------------------------------------------------------------------------

**ID**

nsxv_ability_to_bind_port

**Description**
::

 Verifies that system could manipulate with port.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Log in to Horizon Dashboard.
 Navigate to Project ->  Compute -> Instances

 Launch instance VM_1 with image TestVM-VMDK and flavor m1.tiny.

 Launch instance VM_2  with image TestVM-VMDK and flavor m1.tiny.

 Verify that VMs  should communicate between each other. Send icmp ping from VM _1 to VM_2  and vice versa.
 Disable NSX-v_port of VM_1.
 Verify that VMs  should not communicate between each other. Send icmp ping from VM _2 to VM_1  and vice versa.

 Enable NSX-v_port of VM_1.

 Verify that VMs  should communicate between each other. Send icmp ping from VM _1 to VM_2  and vice versa.
 Pings should get a response

TC-102: Verify that vmclusters should migrate after shutdown controller.
------------------------------------------------------------------------

**ID**

nsxv_shutdown_controller

**Description**
::

 Verify that vmclusters should migrate after shutdown controller.

**Complexity**

core

**Requre to automate**

No

**Steps**
::

 Create a new environment using the Fuel UI Wizard:
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
 network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: all by default

 In Settings tab:
 enable NSX-v plugin

 Add nodes:
 3 controllers

 Setup Fuel interfaces on slaves:
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
 Vlan tag is not set
 Managment: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default
 Click button 'save settings'
 Click button 'verify networks'
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

 Deploy Cluster

 Run OSTF

 Shutdown controller with  vmclusters.

 Check that vmclusters should migrate to another controller.Vmclusters should migrate to another controller.

TC-103: Deploy cluster with plugin, addition and deletion of nodes.
-------------------------------------------------------------------

**ID**

nsxv_add_delete_nodes

**Description**
::

 Verify that system functionality is ok after redeploy.

**Complexity**

advanced

**Requre to automate**

No

**Steps**
::

 Create a new environment using the Fuel UI Wizard:
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
 network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: all by default

 In Settings tab:
 enable NSX-v plugin
 select Vmware vcenter esxi datastore for images (glance)

 Add nodes:
 3 controllers
 2 compute-vmwares
 1 cinder-vmdk

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
 Vlan tag is not set
 Management: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default

 Verify networks

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

 Run OSTF

 Remove node with cinder-vmdk role.

 Add node with cinder role

 Redeploy cluster.

 Run OSTF

 Remove node with compute-vmware role
 Add node with cinder-vmware  role

 Redeploy cluster.

 Run OSTFCluster should be deployed and all OSTF test cases should be passed.

TC-104: Deploy cluster with plugin and deletion one node with controller role.
------------------------------------------------------------------------------

**ID**

nsxv_add_delete_controller

**Description**
::

 Verifies that system functionality is ok when controller has been removed.

**Complexity**

advanced

**Requre to automate**

No

**Steps**
::

 Create a new environment using the Fuel UI Wizard:
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
 network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: all by default

 In Settings tab:
 enable NSX-v plugin
 select Vmware vcenter esxi datastore for images (glance)

 Add nodes:
 4 controller
 1 compute-vmware
 1 cinder-vmdk

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
 Vlan tag is not set
 Management: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default

 Verify networks
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

 Run OSTF
 Remove node with controller role.

 Redeploy cluster

 Run OSTF
 Add controller
 Redeploy cluster

 Run OSTFCluster should be deployed and all OSTF test cases should be passed.

TC-105: Verify that it is not possible to uninstall of Fuel NSX-v plugin with deployed environment.
---------------------------------------------------------------------------------------------------

**ID**

nsxv_plugin

**Description**
::

 It is not possible to remove plugin while at least one environment exists.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Copy plugin to to the Fuel master node using scp.
 Install plugin
 fuel plugins --install plugin-name-1.0-0.0.1-0.noarch.rpm

 Ensure that plugin is installed successfully using cli, run command 'fuel plugins'.
 Connect to the Fuel web UI.

 Create a new environment using the Fuel UI Wizard:
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and Qemu radio button
  network setup : Neutron with tunnel segmentation
  storage backends: default
 additional services: all by default

 Click on the Settings tab.

 In Settings tab:
 enable NSX-v plugin

 Add nodes:
 1 controller

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

 Deploy cluster
 Run OSTF
 Try to delete plugin via cli Remove plugin from master node  fuel plugins --remove plugin-name==1.0.0
 Alert: "400 Client Error: Bad Request (Can't delete plugin which is enabled for some environment.)" should be displayed.

TC-106: Check cluster functionality after reboot vcenter.
---------------------------------------------------------

**ID**

nsxv_plugin

**Description**
::

 Verifies that system functionality is ok when vcenter has been rebooted.

**Complexity**

core

**Requre to automate**

Yes

**Steps**
::

 Create a new environment using the Fuel UI Wizard:
 add name of env and select release version with OS
 as hypervisor type: select vcenter check box and QEMU/KVM radio button
 network setup : Neutron with tunnel segmentation.
 storage backends: default
 additional services: all by default
 In Settings tab:
 enable NSX-v plugin
 select Vmware vcenter esxi datastore for images (glance)

 Add nodes:
 3 controller
 1 computer
 1 cinder-vmware
 1 cinder

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
 Vlan tag is not set
 Management: CIDR '192.168.0.0/24'
 Vlan tag is not set
 Neutron L2 configuration by default
 Neutron L3 configuration by default

 Verify networks

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

 Run OSTF

 Launch instance VM_1 with image TestVM-VMDK and flavor m1.tiny.

 Launch instance VM_2  with image TestVM-VMDK and flavor m1.tiny.

 Check connection between VMs, send ping from VM_1 to VM_2 and vice verse.
 Reboot vcenter
 vmrun -T ws-shared -h https://localhost:443/sdk -u vmware -p VMware01 reset "[standard] vcenter/vcenter.vmx"

 Check that controller lost connection with vCenter

 Wait for vCenter

 Ensure that all instances from vCenter displayed in dashboard.

 Ensure connectivity between vcenter1's and vcenter2's VM.
 Run OSTF
 Cluster should be deployed and all OSTF test cases should be passed. ping should get response.

GUI Testing
===========

TC-131: Verify that all elements of NSX-v plugin section require GUI regiments.
-------------------------------------------------------------------------------

**ID**

nsxv_plugin

**Description**
::

 Verify that all elements of NSX-v plugin section require GUI regiments.

**Complexity**

smoke

**Requre to automate**

Yes

**Steps**
::

 Login to the Fuel web UI.
 Click on the Settings tab.

 Verify that section of NSXv plugin is present on the Settings tab.
 Verify that check box ‘NSXv  plugin’ is disabled by default.

 Verify that user can enabled. Enable NSX-v plugin by click on check box ‘NSXv  plugin’.
 Verify that all labels of NSX-v plugin section have same font style and color.
 Verify that all elements of NSX-v plugin section are vertical aligned.All elements of NSX-v plugin section are required GUI regiments.

