System
======

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
 Launch instances from tcl.vmdk image which is included in plugin package and is available under Horizon.
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
 Launch instance VM_1 with image TestVM-TCL and flavor m1.tiny in vcenter1 az.
 Launch instance VM_2  with image TestVM-TCL and flavor m1.tiny vcenter2 az.
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

 Launch instance VM_1 with image TestVM-TCL and flavor m1.tiny in vcenter1 az.

 Launch instance VM_2 with image TestVM-TCL and flavor m1.tiny in vcenter2 az.

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

 Launch instances VM_1 and VM_2 in the network192.168.101.0/24 with image TestVM-TCL and flavor m1.tiny in vcenter1 az.

 Launch instances VM_3 and VM_4 in the 192.168.102.0/24 with image TestVM-TCL and flavor m1.tiny in vcenter2 az.

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
 Launch instance VM_1 in the provider network with image TestVM-TCL and flavor m1.tiny in the vcenter1 az.

 Launch instance VM_2  in the provider network  with image TestVM-TCL and flavor m1.tiny in the vcenter2 az.

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
 Launch instance VM_1 in the provider network with image TestVM-TCL and flavor m1.tiny in the vcenter1 az.

 Launch instance VM_2  in the provider network  with image TestVM-TCL and flavor m1.tiny in the vcenter2 az.

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
 Launch instance VM_1 of vcenter1 AZ with image TestVM-TCL and flavor m1.tiny in the net_04.
 Launch instance VM_1 of vcenter2 AZ with image TestVM-TCL and flavor m1.tiny in the net_01.
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
 Launch instance VM_1 of vcenter1 AZ with image TestVM-TCL and flavor m1.tiny in the net_04. Associate floating ip.

 Launch instance VM_1 of vcenter2 AZ with image TestVM-TCL and flavor m1.tiny in the net_01. Associate floating ip.

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
 Launch instance VM_1 in the tenant network net_02 with image TestVM-TCL and flavor m1.tiny in the vcenter1 az.
 Launch instance VM_2  in the tenant net_02  with image TestVM-TCL and flavor m1.tiny in the vcenter2 az.

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
 Launch 5 instance VM_1 simultaneously with image TestVM-TCL and flavor m1.micro in vcenter1 az in default net_04

 All instance should be created without any error.

 Launch 5 instance VM_2 simultaneously with image TestVM-TCL and flavor m1.micro in vcenter2 az in default net_04

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

