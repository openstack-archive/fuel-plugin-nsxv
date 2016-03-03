=====
Smoke
=====


Install Fuel VMware NSX-v plugin.
---------------------------------


ID
##

nsxv_install


Description
###########

Check that plugin can be installed.


Complexity
##########

smoke


Steps
#####

    1. Connect to fuel node via ssh.
    2. Upload plugin.
    3. Install plugin.


Expected result
###############
Output::

 [root@nailgun ~]# fuel plugins --install nsxv-2.0-2.0.0-1.noarch.rpm
 Loaded plugins: fastestmirror, priorities
 Examining nsxv-2.0-2.0.0-1.noarch.rpm: nsxv-2.0-2.0.0-1.noarch
 Marking nsxv-2.0-2.0.0-1.noarch.rpm to be installed
 Resolving Dependencies
 --> Running transaction check
 ---> Package nsxv-2.0.noarch 0:2.0.0-1 will be installed
 --> Finished Dependency Resolution

 Dependencies Resolved


  Package Arch Version Repository Size
 Installing:
  nsxv-2.0 noarch 2.0.0-1 /nsxv-2.0-2.0.0-1.noarch 20 M

 Transaction Summary
 Install  1 Package

 Total size: 20 M
 Installed size: 20 M
 Downloading packages:
 Running transaction check
 Running transaction test
 Transaction test succeeded
 Running transaction
   Installing : nsxv-2.0-2.0.0-1.noarch 1/1
   Ssh key file exists, skip generation
   Verifying  : nsxv-2.0-2.0.0-1.noarch 1/1

 Installed:
   nsxv-2.0.noarch 0:2.0.0-1

 Complete!
 Plugin nsxv-2.0-2.0.0-1.noarch.rpm was successfully installed.

Ensure that plugin is installed successfully using cli, run command 'fuel plugins'. Check name, version and package version of plugin.


Uninstall Fuel VMware NSXv plugin.
-----------------------------------


ID
##

nsxv_uninstall


Description
###########

Check that plugin can be removed.


Complexity
##########

smoke


Steps
#####

    1. Connect to fuel node with preinstalled plugin via ssh.
    2. Remove plugin.


Expected result
###############
Output::

 [root@nailgun ~]# fuel plugins --remove nsxv==2.0.0
 Loaded plugins: fastestmirror, priorities
 Resolving Dependencies
 --> Running transaction check
 ---> Package nsxv-2.0.noarch 0:2.0.0-1 will be erased
 --> Finished Dependency Resolution

 Dependencies Resolved

  Package  Arch  Version Repository Size
 Removing:
  nsxv-2.0 noarch 2.0.0-1 @/nsxv-2.0-2.0.0-1.noarch 20 M

 Transaction Summary
 Remove  1 Package

 Installed size: 20 M
 Downloading packages:
 Running transaction check
 Running transaction test
 Transaction test succeeded
 Running transaction
   Erasing    : nsxv-2.0-2.0.0-1.noarch 1/1
   Verifying  : nsxv-2.0-2.0.0-1.noarch 1/1

 Removed:
   nsxv-2.0.noarch 0:2.0.0-1

 Complete!
 Plugin nsxv==2.0.0 was successfully removed.

Verify that plugin is removed, run command 'fuel plugins'.


Verify that all elements of NSXv plugin section meets the requirements.
-----------------------------------------------------------------------


ID
##

nsxv_gui


Description
###########

Verify that all elements of NSXv plugin section meets the requirements.


Complexity
##########

smoke


Steps
#####

    1. Login to the Fuel web UI.
    2. Click on the Networks tab.
    3. Verify that section of NSXv plugin is present under the Other menu option.
    4. Verify that check box 'NSXv plugin' is enabled by default.
    5. Verify that all labels of 'NSXv plugin' section have the same font style and colour.
    6. Verify that all elements of NSXv plugin section are vertical aligned.


Expected result
###############

All elements of NSXv plugin section are regimented.


Deployment with plugin, controller and vmware datastore backend.
----------------------------------------------------------------


ID
##

nsxv_smoke


Description
###########

Check deployment with NSXv plugin and one controller.


Complexity
##########

smoke


Steps
#####

    1. Log into Fuel with preinstalled plugin.
    2. Create a new environment with following parameters:
        * Compute: KVM/QEMU with vCenter
        * Networking: Neutron with tunnel segmentation
        * Storage: default
        * Additional services: default
    3. Add nodes with following roles:
        * Controller
    4. Configure interfaces on nodes.
    5. Configure network settings.
    6. Enable and configure NSXv plugin.
    7. Configure settings:
        * Enable VMWare vCenter/ESXi datastore for images (Glance).
    8. Configure VMware vCenter Settings. Add 1 vSphere cluster and configure Nova Compute instances on conrollers.
    9. Deploy cluster.
    10. Run OSTF.


Expected result
###############

Cluster should be deployed and all OSTF test cases should be passed.


Deploy HA cluster with NSXv plugin.
------------------------------------


ID
##

nsxv_bvt


Description
###########

Check deployment with NSXv plugin, 3 Controllers, 2 CephOSD, CinderVMware and computeVMware roles.


Complexity
##########

smoke


Steps
#####

    1. Connect to the Fuel web UI with preinstalled plugin.
    2. Create a new environment with following parameters:
        * Compute: KVM/QEMU with vCenter
        * Networking: Neutron with tunnel segmentation
        * Storage: Ceph RBD for images (Glance)
        * Additional services: default
    3. Add nodes with following roles:
        * Controller
        * Controller
        * Controller
        * CephOSD
        * CephOSD
        * CinderVMware
        * ComputeVMware
    4. Configure interfaces on nodes.
    5. Configure network settings.
    6. Enable and configure NSXv plugin.
    7. Configure VMware vCenter Settings. Add 2 vSphere clusters and configure Nova Compute instances on conrollers and compute-vmware.
    8. Verify networks.
    9. Deploy cluster.
    10. Run OSTF.


Expected result
###############

Cluster should be deployed and all OSTF test cases should be passed.


Verify that nsxv driver configured properly after enabling NSXv plugin
-----------------------------------------------------------------------


ID
##

nsxv_config_ok


Description
###########

Need to check that all parameters of nsxv driver config files have been filled up with values entered from GUI. Applicable values that are typically used are described in plugin docs. Root & intermediate certificate are signed, in attachment.


Complexity
##########

advanced


Steps
#####

    1. Install NSXv plugin.
    2. Enable plugin on tab Settings -> NSXv plugin.
    3. Fill the form with corresponding values.
    4. Uncheck option "Bypass NSX Manager certificate verification".
    5. Do all things that are necessary to provide interoperability of NSXv plugin and NSX Manager with certificate.
    6. Check Additional settings. Fill the form with corresponding values. Save settings by pressing the button.


Expected result
###############

Check that nsx.ini on controller nodes is properly configured.

