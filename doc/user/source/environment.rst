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

#. After plugin gets installed it will be possible to use *Neutron with
   NSXv plugin* at 'Networking Setup' step:

   .. image:: /image/wizard-step2.png
      :scale: 70 %

#. Once you get environment created add one or more controller node.

Pay attention on which interface you assign *Public* network, OpenStack
controllers must have connectivity with NSX Manager host through *Public*
network since it is used as default route for packets.

Is is worth to mention that it is not possible to use compute nodes in this
type of cluster, because NSX switch is available only for ESXi, so it is not
possible to pass traffic inside compute node that runs Linux and KVM.  Also it
does not matter on which network interface you assign *Private* traffic,
because it does not flow through controllers.

*Floating IP range* settings on Networks are not used by the plugin, because it
user interface restricts specifying IP range is not within *Public* network
range.  Plugin has its own *Floating IP range* setting.

.. image:: /image/floating-ip.png
   :scale: 70 %

Pay attention that Neutron L2/L3 configuration on Settings tab does not have
effect in OpenStack cluster that uses NSXv.  These settings contain settings
for GRE tunneling which does not have an effect with NSXv.

During deployment process plugin creates simple network topology for admin
tenant. It creates provider network which connects tenants with transport
(physical) network, one internal network and router that is connected to both
networks.

