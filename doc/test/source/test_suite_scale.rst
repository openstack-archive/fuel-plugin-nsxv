=====
Scale
=====


Deploy cluster with plugin and deletion one node with controller role.
----------------------------------------------------------------------


ID
##

nsxv_add_delete_controller


Description
###########

Verifies that system functionality is ok when controller has been removed.


Complexity
##########

core


Steps
#####

    1. Log into Fuel with preinstalled plugin.
    2. Create a new environment with following parameters:
        * Compute: KVM/QEMU with vCenter
        * Networking: Neutron with tunnel segmentation
        * Storage: default
    3. Add nodes with following roles:
        * Controller
        * Controller
        * Controller
        * Controller
        * CinderVMware
        * ComputeVMware
    4. Configure interfaces on nodes.
    5. Configure network settings.
    6. Enable and configure NSXv plugin.
    7. Configure VMware vCenter Settings. Add 2 vSphere clusters and configure Nova Compute instances on conrollers and compute-vmware.
    8. Deploy cluster.
    9. Run OSTF.
    10. Remove node with controller role.
    11. Redeploy cluster.
        Check that all instances are in place.
    12. Run OSTF.
    13. Add controller.
    14. Redeploy cluster.
        Check that all instances are in place.
    15. Run OSTF.


Expected result
###############

Cluster should be deployed and all OSTF test cases should be passed.


Deployment with 3 Controlers, ComputeVMware, CinderVMware and check adding/deleting of nodes.
---------------------------------------------------------------------------------------------


ID
##

nsxv_add_delete_nodes


Description
###########

Verify that system functionality is ok after redeploy.


Complexity
##########

advanced


Steps
#####

    1. Connect to a Fuel web UI with preinstalled plugin.
    2. Create a new environment with following parameters:
        * Compute: KVM/QEMU with vCenter
        * Networking: Neutron with VLAN segmentation
        * Storage: default
        * Additional services: default
    3. Add nodes with following roles:
        * Controller
        * Controller
        * Controller
        * ComputeVMware
    4. Configure interfaces on nodes.
    5. Configure network settings.
    6. Enable and configure NSXv plugin.
    7. Configure VMware vCenter Settings. Add 2 vSphere clusters and configure Nova Compute instances on controllers and compute-vmware.
    8. Deploy cluster.
    9. Run OSTF.
    10. Add node with CinderVMware role.
        Redeploy cluster.
    11. Run OSTF.
    12. Remove node with CinderVMware role.
        Redeploy cluster.
    13. Run OSTF.
    14. Remove node with ComputeVMware role.
        Redeploy cluster.
    15. Run OSTF.


Expected result
###############

Changing of cluster configuration was successful. Cluster should be deployed and all OSTF test cases should be passed.

