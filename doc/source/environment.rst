OpenStack environment notes
===========================

To use NSXv plugin create new OpenStack environment via Fuel web UI.

On 'Compute' configuration step tick 'vCenter' checkbox

.. image:: /image/wizard-step1.png
   :scale: 70 %

After plugin gets installed it updates Fuel and it will be possible to use
'Neutron with tunneling segmentation' at 'Networking Setup' step:

.. image:: /image/wizard-step2.png
   :scale: 70 %

Once you get environment created add one or more controller node.

Is is worth to mention that it is not possible to use compute nodes in this
type of cluster, because NSX Controllers and NSX Edge nodes run on top of ESXi
hosts as virtual machines this means that NSXv can manage VMs traffic on ESXi
hosts have NSXv switch installed.  Also it does not matter on which network
interface
you assign 'VM fixed' traffic, because it does not flow through controllers.

Pay attention that Neutron L2/L3 configuration on Settings tab does not have
effect in OpenStack cluster that uses NSXv.

.. image:: /image/neutron-network-settings.png
   :scale: 70 %

Plugin cannot deploy vCenter and NSXv, they must be up and running before
deployment of OpenStack cluster starts.


