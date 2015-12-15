Integration
===========


Deploy cluster with NSX-v plugin and ceilometer.
------------------------------------------------


ID
##

nsxv_ceilometer


Description
###########

Check deployment with Fuel NSXv plugin and Ceilometer.


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
        * Additional services: ceilometer
    3. Add nodes with following roles:
        * Controller + Mongo
        * Controller + Mongo
        * Controller + Mongo
        * ComputeVMware
    4. Configure interfaces on nodes.
    5. Configure network settings.
    6. Enable and configure NSXv plugin.
    7. Configure VMware vCenter Settings. Add 2 vSphere clusters and configure Nova Compute instances on controllers and compute-vmware.
    8. Verify networks.
    9. Deploy cluster.
    10. Run OSTF.


Expected result
###############

Cluster should be deployed and all OSTF test cases should be passed.

