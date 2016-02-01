Release notes
=============

Release notes for Fuel NSXv plugin 2.0.0:

  * Support for Neutron server Liberty release.
  * Add new parameters that were added during Liberty release.
  * Support of Fuel `component registry feature
    <https://blueprints.launchpad.net/fuel/+spec/component-registry>`_.
    Plugin is shown as separate item at network step of cluster creation
    wizard.
  * Plugin no longer ships customized python-nova package. All needed
    functionality for NSX support is available in python-nova Liberty package.
  * Plugin installation process takes less time, because it does not restart
    docker containers.
  * Enable Neutron load balancer functionality.
  * Create Neutron networks in admin tenant during deployment process.
  * Documentation improvements.
  * List Vcenter Clusters plugin takes from "Vmvare" tab settings and
    automatically converts to Cluster MoRef IDs.

Release notes for Fuel NSXv plugin 1.2.0:

  * Fix bug `LP1527594 <https://bugs.launchpad.net/fuel/+bug/1527594>`_.
  * Provide python script that can restore cluster restrictions.
  * Documentation improvements.
