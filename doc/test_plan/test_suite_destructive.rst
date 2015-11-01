Destructive
===========

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

