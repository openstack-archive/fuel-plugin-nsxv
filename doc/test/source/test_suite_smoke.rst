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

Ensure that plugin is installed successfully using cli, run command 'fuel plugins'. Check name, version and package version of plugin.


Uninstall Fuel VMware NSX-v plugin.
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
    2. Click on the Settings tab.
    3. Verify that section of NSXv plugin is present on the Settings tab.
    4. Verify that check box 'NSXv  plugin' is disabled by default.
    5. Verify that user can enabled. Enable NSX-v plugin by click on check box 'NSXv  plugin'.
    6. Verify that all labels of NSX-v plugin section have same font style and color.
    7. Verify that all elements of NSX-v plugin section are vertical aligned.


Expected result
###############

All elements of NSX-v plugin section are required GUI regiments.


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
    9. Verify networks.
    10. Deploy cluster.
    11. Run OSTF.


Expected result
###############

Cluster should be deployed and all OSTF test cases should be passed.


Deploy HA cluster with NSX-v plugin.
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

    1. Connect to a Fuel web UI with preinstalled plugin.
    2. Create a new environment with following parameters:
        * Compute: KVM/QEMU with vCenter
        * Networking: Neutron with tunnel segmentation
        * Storage: Ceph
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


Verify that nsxv driver configured properly after enabling NSX-v plugin
-----------------------------------------------------------------------


ID
##

nsxv_config_ok


Description
###########

Need to check that all parameters of nsxv driver config files have been filled up with values entered from GUI. Applicable values that are typically used are described in plugin docs. Root & intermediate certificate are signed, in attachment.


Complexity
##########

smoke


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

