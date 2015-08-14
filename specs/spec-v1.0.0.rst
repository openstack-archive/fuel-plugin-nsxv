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

Plugin will be compatible with Fuel 7.0.

Starting from Fuel 6.1 it is possible to deploy dual-hypervisor cloud, e.g. it
is possible to use VMware vCenter and KVM computes in single OpenStack
environment.  In OpenStack environment with NSXv plugin it will be not possible
to use KVM/QEMU compute nodes, because NSXv networking platform is not
supported by KVM hypervisor.

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
  | |    | NSXV   |  |   +----------+        |   |  +---------+  |        |
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


Alternatives
------------

None.

Data model impact
-----------------

Plugin will produce following array of settings into astute.yaml:

.. code-block:: yaml

  nsxv:
    - username: nsxvadmin
      password: p8cRhToVhT
      transport_zone: VLXLAN-global
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
