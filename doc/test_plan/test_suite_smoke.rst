Smoke
=====

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

