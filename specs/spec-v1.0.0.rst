..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

===========================================
Fuel Plugin for VMware NSXv SDN integration
===========================================

NSXv plugin for Fuel provides an ability to deploy OpenStack cluster that is
utilizing vCenter computing clusters and NSXv network virtualization
platform [1]_.

Problem description
===================

Fuel functionality does not allow user to deploy OpenStack over vCenter and NSX
infrastructure out-of-the-box.  Major efforts are required to deploy and then
reconfigure OpenStack with Neutron to use vCenter and NSX.  Plugin automates
deployment process to reduce human error that can be made during
reconfiguration process.

Proposed change
===============

Implement a Fuel plugin [2]_ which will deploy NSXv plugin for OpenStack networking
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

                                            +----------------------------+
                                            |  Compute cluster           |
                                            |                            |
                            OpenStack       |   +---------------+        |
                            Public network  |   |               |        |
 +----------------------+          +        |   |   ESXi host   |        |
 |                      |          |        |   |               |        |
 | OpenStack Controller |          |        |   |  +---------+  |        |
 |                      |          |        |   |  |         |  |        |
 | +----------------+   |          +---------------+ vCenter |  |        |
 | |                |   |          |        |   |  | server  |  |        |
 | | Neutron server |   |          |        |   |  |         |  |        |
 | |                |   |          |        |   |  +---------+  |        |
 | |    +--------+  |   |          |        |   |               |        |
 | |    |        |  |   |          |        |   +---------------+        | VXLAN tunnels
 | |    | NSXv   |  |   +----------+        |                            |     +
 | |    | plugin |  |   |          |        |   +--------------------+   |     |
 | |    |        |  |   |          |        |   |            +-----+ |   |     |
 | |    +--------+  |   |          |        |   | ESXi host  |     | |   |     |
 | |                |   |          |        |   |            | VM  +-----------+
 | +----------------+   |          |        |   |            |     | |   |     |
 +----------------------+          |        |   |            +-----+ |   |     |
                                   |        |   +--------------------+   |     |
                                   |        |                            |     |
                                   |        |   +--------------------+   |     |
                                   |        |   |                    |   |     |
                                   |        |   | ESXi host  +-----+ |   |     |
                                   |        |   |            |     | |   |     |
                                   |        |   |            | VM  +-----------+
                                   |        |   |            |     | |   |     |
                                   |        |   |            +-----+ |   |     |
                                   |        |   +--------------------+   |     |
                                   |        +----------------------------+     |
                                   |                                           |
                                   |        +----------------------------+     |
                                   |        |                            |     |
                                   |        |  NSXv Management cluster   |     |
                                   |        |                            |     |
                                   +--------+ ESXi host                  |     |
                                   |        | +-----------+              |     |
                                   |        | |           |              |     |
                                   |        +-+  NSX ESG  +--------------------+
                                   |        | |           |              |     |
                                   |        | +-----------+              |     |
                                   +        +----------------------------+     +




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
#. Remove nova-network service out of OpenStack database
#. Deploy HA-proxy neutron
#. Install neutron-server
#. Configure neutron-server
#. Install Neutron NSXv plugin
#. Configure the plugin
#. Start Neutron server under pacemaker supervision
#. Install customized nova-python package
#. Configure nova-compute to use Neutron as network provider
#. Restart related nova services (nova-api-metadata, nova-compute)

#. Install Neutron NSXv plugin
#. Configure the plugin
#. Prepare DB for Neutron
#. Setup Keystone account for Neutron
#. Configure haproxy
#. Install neutron-server package
#. Configure nova-compute to Neutron as network API
#. Restart Nova related services
#. Stop nova-network service and remove it corosync database


Deployment diagram:

::

 NSXv manifests                  Nova-network  Neutron-server

       +                             +
       |  Install customized         |
       |  python-nova package        |
       |                             |
       |  Prepare data for Neutron   |
       |  deployment tasks           |
       |                             |
       |  Stop nova-network          |
       |  pacemaker resource         |
       |  +------------------------> +
       |
       |  Remove nova-network entry
       |  out of OpenStack DB
       |
       |  Deploy ha-proxy
       |
       |  Install neutron-server
       |
       |  Install NSXv plugin
       |
       |  Configure neutron-server with NSXv
       |
       |  Start Neutron-server
       |  +---------------------------------->   +
       |                                         |
       |                                         |
       |                                         |
       v                                         v


Plugin will be compatible with Fuel 7.0.


Alternatives
------------

None.

Data model impact
-----------------

Plugin will produce following array of settings into astute.yaml:

.. code-block:: yaml

  nsxv:
    nsxv_manager_ip:
      value: 172.16.0.249
    nsxv_user:
      value: admin
    nsxv_password:
      value: r00tme
    nsxv_datacenter_moid:
      value: datacenter-126
    nsxv_cluster_moid:
      value: domain-c133,domain-c134,domain-c138
    nsxv_resource_pool_id:
      value: resgroup-134
    nsxv_datastore_id:
      value: datastore-138
    nsxv_external_network:
      value: network-222
    nsxv_vdn_scope_id:
      value: vdnscope-1
    nsxv_dvs_id:
      value: dvs-141
    nsxv_backup_edge_pool:
      value: service:compact:1:2,vdr:compact:1:2

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

User experience will be awkward with NSXv plugin, user have to select
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

Since it is not possible for user to select any Neutron option in 'Create a new
OpenStack environment' wizard deployment serializer would not be able to
generate network data for Neutron granular deployment tasks.  This obstacle can
be overcome with custom puppet class that will prepare nova-network
parameters for neutron manifests.  Only after that it will be possible to
utilize neutron deployment tasks from fuel-library [3]_.


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

.. [1] NSX for vSphere getting started guide
  https://communities.vmware.com/servlet/JiveServlet/previewBody/27705-102-1-37093/NSXv-GSG.pdf
.. [2] Fuel Plug-in Guide http://docs.mirantis.com/openstack/fuel/fuel-6.0/plugin-dev.html
.. [3] https://github.com/stackforge/fuel-library
