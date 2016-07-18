OpenStack environment notes
===========================

Environment creation
--------------------

Before you start the actual deployment, verify that your vSphere
infrastructure (vCenter and NSXv) is configured and functions properly.
The Fuel NSXv plugin cannot deploy vSphere infrastructure; The
vSphere infrastructure must be up and running before the OpenStack deployment.

To use the NSXv plugin, create a new OpenStack environment using the Fuel web
UI by doing the following:

#. On the :guilabel:`Compute` configuration step, tick the :guilabel:`vCenter`
   checkbox:

   .. image:: /image/wizard-step1.png
      :scale: 70 %

#. After the plugin installation, use :guilabel:`Neutron with
   NSXv plugin` at the :guilabel:`Networking Setup` step:

   .. image:: /image/wizard-step2.png
      :scale: 70 %

#. Once you get the environment created, add one or more controller nodes.

Pay attention to on which interface you assign the *Public* network. The
OpenStack controllers must have connectivity with the NSX Manager host
through the *Public* network since the *Public* network is the default
route for packets.

During the deployment, the plugin creates a simple network topology for
the admin tenant. The plugin creates a provider network which connects the
tenants with the transport (physical) network: one internal network and
a router that is connected to both networks.

