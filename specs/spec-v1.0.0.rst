..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

===========================================
Fuel Plugin for VMware NSXv SDN integration
===========================================

NSXv plugin for Fuel provides an ability to deploy OpenStack cluster that is
utilizing vCenter computing clusters and NSXv network virtualization platform.

Problem description
===================

Proposed change
===============

Implement a Fuel plugin which will deploy NSXv plugin for OpenStack networking
service (Neutron) and configure it.

Plugin assumes that end user already has vCenter with NSXv up and running.

Starting from Fuel 6.1 it is possible to deploy dual-hypervisor cloud, e.g. it
is possible to use VMware vCenter and KVM computes in single OpenStack
environment.  In OpenStack environment with NSXv plugin it will be not possible
to use KVM/QEMU compute nodes, because NSXv networking platform is not
supported by KVM hypervisor.

Plugin components will include:

- customized nova packages (python-nova)
- task for generating appropriate data for Neutron deployment
- puppet manifests for installation and configuration Neutron NSXv plugin

In Fuel 7.0 when user marks vCenter checkbox in 'Compute' step of 'Create a new
OpenStack environment' wizard it leads to inability to select Neutron in
'Networking setup' step, because in Fuel 7.0 the only available network backend
for vCenter is nova-network.

Architecture diagram

::

                             OpenStack       +----------------------------+
                             Public network  |  Compute cluster           |
  +----------------------+          +        |                            |
  |                      |          |        |   +---------------+        |
  | OpenStack Controller |          |        |   |               |        |
  |                      |          |        |   |   ESXi host   |        |
  | +----------------+   |          |        |   |               |        |
  | |                |   |          |        |   |  +---------+  |        |
  | | Neutron server |   |          |        |   |  |         |  |        |
  | |                |   |          +---------------+ vCenter |  |        |
  | |    +--------+  |   |          |        |   |  | server  |  |        |
  | |    |        |  |   |          |        |   |  |         |  |        |
  | |    | NSXv   |  |   +----------+        |   |  +---------+  |        |
  | |    | plugin |  |   |          |        |   |               |        |
  | |    |        |  |   |          |        |   +---------------+        |
  | |    +--------+  |   |          |        |                            |
  | |                |   |          |        |   +---------------+        |
  | +----------------+   |          |        |   |               |        |
  +----------------------+          |        |   | ESXi host     |        |
                                    |        |   |               |        |
                                    |        |   +---------------+        |
                                    |        +----------------------------+
                                    |
                                    |        +----------------------------+
                                    |        |                            |
                                    |        |  NSXv Management cluster   |
                                    |        |                            |
                                    +--------+ ESXi host                  |
                                    |        | +-----------+              |
                                    |        | |           |              |
                                    |        +-+  NSX ESG  |              |
                                    |        | |           |              |
                                    |        | +-----------+              |
                                    +        |                            |
                                             +----------------------------+


VM creation workflow:

::

                                   Neutron server
  Nova-api      Nova-compute       (NSXv plugin)     NSXv Manager   vCenter server
      +            +                   +               +                 +
      |            |                   |               |                 |
      |            |                   |               |                 |
      | Create VM  |                   |               |                 |
      |            |                   |               |                 |
      | <--------> |   Provision port  |               |                 |
      |            |   for VM          |               |                 |
      |            |  <------------->  |               |                 |
      |            |                   |  Create port  |                 |
      |            |                   | <-----------> +---+             |
      |            |                   |               |   |             |
      |            |                   | Port ready    |   |             |
      |            |  Port with UUID N | <-----------> +---+             |
      |            |  ready            |               |                 |
      |            |  <------------->  |               |                 |
      |            |                   |               |                 |
      |            |                   |               |                 |
      |            |  Create VM and attach to port with UUID N           |
      |            | <-------------------------------------------------> +--+
      |            |                   |               |                 |  |
      |            |  VM is ready      |               |                 |  |
      |            | <-------------------------------------------------> +--+
      |            |                   |               |                 |
      +            +                   +               +                 +


Plugin work items in pre-deployment stage:

#. Generate data for Neutron:

  - username
  - password
  - database connection

Plugin actions in post-deployment stage:

#. Stop nova-network pacemaker resource
#. Install neutron-server
#. Configure neutron-server
#. Install Neutron NSXv plugin
#. Configure the plugin
#. Start Neutron server under pacemaker supervision
#. Install customized nova-python package
#. Configure nova-compute to use Neutron as network provider
#. Restart related nova services (nova-api-metadata, nova-compute)

Plugin will be compatible with Fuel 7.0.


Alternatives
------------

None.

Data model impact
-----------------

Plugin will produce following array of settings into astute.yaml:

.. code-block:: yaml

  nsxv:
    - nsxv_endpoint: https://172.16.0.240
      username: nsxvadmin
      password: p8cRhToVhT
      datacenter_moid: TBD
      cluster_moid: TBD
      external_network: TBD
      transport_zone: VXLAN-global
      edge_cluster: TBD
      vtep_vds: TBD
      external_portgroup: TBD

REST API impact
---------------

None.

Upgrade impact
--------------

None.

Security impact
---------------

None.

Notifications impact
--------------------

None.

Other end user impact
---------------------

Plugin settings are available via the Settings tab on Fuel web UI.

User has to extract needed settings out of vCenter and enter these settings on
the settings tab.

It does not matter at what interface end user will assign 'VM fixed' network
(aka Private network) where VM traffic flows on Controller node, because all VM
traffic including DHCP and L3 services is terminated inside vSphere
infrastructure.

User experience will look awkward with NSXv plugin, user have to select
nova-network backend when he creates new OpenStack environment in Fuel web UI.
After enabling NSXv plugin for this environment Neutron will be deployed as
network provider.  From user perspective it looks awkward.

Performance Impact
------------------

None.

Other deployer impact
---------------------

None.

Developer impact
----------------

None.


Implementation
==============

Assignee(s)
-----------

Primary assignee:

- Igor Zinovik <izinovik@mirantis.com> - feature lead, developer

Other contributors:

- Artem Savinov <asavinov@mirantis.com> - developer

Project manager:

- Andrian Noga <anoga@mirantis.com>

Quality assurance:

- Andrey Setyaev <asetyaev@mirantis.com>


Work Items
----------

* Create pre-dev environment and manually deploy vCenter with NSXv

* Create Fuel plugin bundle, which contains deployments scripts, puppet
  modules and metadata

* Implement puppet module with the following functions:

 - Install Neutron NSXv plugin on OpenStack controllers
 - Configure Neutron server to use NSXv plugin and reload its configuration
 - Create needed networks for OpenStack testing framework (OSTF)

* Create system test for the plugin

* Write documentation


Dependencies
============

* Fuel 7.0

* VMware NSXv support in Nova
  https://blueprints.launchpad.net/nova/+spec/vmware-nsxv-support

* VMware NSXv plugin for Neutron

  https://blueprints.launchpad.net/neutron/+spec/vmware-nsx-v

  https://github.com/openstack/vmware-nsx

* NSXv support for Nova (Kilo)

  https://review.openstack.org/#/c/209372/

  https://review.openstack.org/#/c/209374/

Testing
=======

* Sanity checks including plugin build
* Syntax check
* Functional testing
* Non-functional testing
* Destructive testing

Documentation Impact
====================

* Deployment Guide (how to prepare an env for installation, how to
  install the plugin, how to deploy OpenStack env with the plugin)
* User Guide (which features the plugin provides, how to use them in
  the deployed OS env)

References
==========

* NSX for vSphere getting started guide
  https://communities.vmware.com/servlet/JiveServlet/previewBody/27705-102-1-37093/NSXv-GSG.pdf
* Fuel Plug-in Guide http://docs.mirantis.com/openstack/fuel/fuel-6.0/plugin-dev.html
