OpenStack environment notes
===========================

Environment creation
--------------------

Before start actual deployment process please verify that you vSphere
infrastructure (vCenter and NSXv) is configured and functions properly,
Fuel NSXv plugin cannot deploy vSphere infrastructure, it must be up and
running before OpenStack deployment.

To use NSXv plugin create new OpenStack environment via the Fuel web UI follow
these steps:

#. On *Compute* configuration step tick 'vCenter' checkbox

   .. image:: /image/wizard-step1.png
      :scale: 70 %

#. After plugin gets installed it updates Fuel and it will be possible to use
   *Neutron with tunneling segmentation* at 'Networking Setup' step:

   .. image:: /image/wizard-step2.png
      :scale: 70 %

   .. warning::

      After Fuel database gets updated it is possible to enable Murano support
      for cloud with NSX, but Murano functionality was not tested with NSX.

#. Once you get environment created add one or more controller node.

Pay attention on which interface you assign *Public* network, Controller must
have connectivity with NSX Manager host through *Public* network since it is
used as default route for packets.

Is is worth to mention that it is not possible to use compute nodes in this
type of cluster, because NSX switch is not available for Linux only for ESXi,
so it is not possible to pass traffic inside compute node that runs Linux and
KVM.  Also it does not matter on which network interface you assign 'VM fixed'
traffic, because it does not flow through controllers.

*Floating IP ranges* are not used, because Neutron L3 agent is not used on
Controller.

.. image:: /image/floating-ip.png
   :scale: 70 %

Pay attention that Neutron L2/L3 configuration on Settings tab does not have
effect in OpenStack cluster that uses NSXv.  These settings contain settings
for GRE tunneling which does not have an effect with NSXv.

.. image:: /image/neutron-network-settings.png
   :scale: 70 %

Public network assignment
-------------------------

If you are going to use *Cinder proxy to VMware datastore* or *Compute VMware*
roles in your environment then you have to assign public IP addresses to all
nodes, because all communication between OpenStack services (Cinder and Nova in
this case) and vCenter happens via Public network.

You can achieve this by enabling following option (*Settings -> Public network
assignment -> Assign public network to all nodes*):

.. image:: /image/public-network-assignment.png
   :scale: 70 %
