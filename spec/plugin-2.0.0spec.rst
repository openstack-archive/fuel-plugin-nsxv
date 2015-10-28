..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

==================================================
Fuel Plugin v2.0.0 for VMware NSXv SDN integration
==================================================

NSXv plugin for Fuel provides an ability to deploy OpenStack cluster that is
utilizing vCenter compute clusters and NSXv network virtualization
platform.

Problem description
===================

Upcoming Neutron server manifests refactoring [0]_ breaks backward compatibility for
Fuel NSXv plugin v1.0.0.  Deployment manifests of the plugin must be adjusted
according to this change.

Proposed change
===============

Plugin changes can be summarized in the following list:

 * Refactor puppet deployment manifests.

 * Fuel 8.0 will be extended with component registry feature [1]_.  This will
   allow plugin implement its own option in cluster creation wizard, which will
   significantly simplify interaction with Nailgun database.  Plugin will not
   need to update Nailgun database to enable Neutron networking option for
   vCenter.  Plugin installation will be much faster, since we no longer need
   to wait for docker container restart.

 * Fuel 8.0 will shipped with OpenStack Liberty.  Neutron NSX plugin must be
   updated to new version.

 * During OpenStack Liberty development cycle new configuration options were
   added to Neutron NSX plugin (**exclusive_router_appliance_size**,
   **edge_appliance_user**, **edge_appliance_password**, **dhcp_lease_time**).
   Plugin should provide input fields for this options on its page with
   settings.

 * Plugin must create predefined networks (*net04*, *net04_ext*) in order to
   allow end user start OSTF checks against deployed cloud.

 * Nova project merged changes required for NSX support in Liberty release.
   This means that plugin package do not need to carry customized python-nova
   package.  It must be dropped.

Plugin assumes that end user already has vCenter with NSXv up and running.

In OpenStack environment with NSXv plugin it will be not possible
to use KVM/QEMU compute nodes, because NSXv networking platform is not
supported by KVM hypervisor.

Plugin will be compatible with Fuel 8.0.


Alternatives
------------

None.

Data model impact
-----------------

New values will be added into astute.yaml:

.. code-block:: yaml

  nsxv:
  ...
    nsxv_exclusive_router_appliance_size:
      value: large
      description: "Edge form factor for exclusive router"
      regex: ^(compact|large|quadlarge|xlarge)$
    nsxv_edge_appliance_user:
      value: root
      description: "User for Edge node login"
    nsxv_edge_appliance_password:
      value: p@sSw0rD+
      description: "Password for Edge node login"
    nsxv_dhcp_lease_time:
      value: 86400
      description: "DHCP lease time"

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

None.

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

* Remove .deb package python-nova

* Rewrite puppet manifests

* Add option in cluster creation wizard

* Create predefined network in post-deployment stage

* Perform regression tests

* Update documentation


Dependencies
============

* Fuel 8.0

* Component registry
  https://blueprints.launchpad.net/nova/+spec/component-registry

* Granular Neutron deployment
  https://blueprints.launchpad.net/fuel/+spec/make-neutron-deployment-task-more-granular

Testing
=======

* Sanity checks including plugin build
* Syntax check
* Functional testing
* Non-functional testing
* Destructive testing

Documentation Impact
====================

Documentation need to be updated to implemented changes.

References
==========

.. [0] Granular Neutron deployment tasks
  https://blueprints.launchpad.net/fuel/+spec/make-neutron-deployment-task-more-granular
.. [1] Component registry for Fuel
  https://blueprints.launchpad.net/fuel/+spec/component-registry
