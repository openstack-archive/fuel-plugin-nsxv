Release notes
=============

Release notes for Fuel NSXv plugin 2.0.0:

  * Plugin is compatible with Fuel 8.0.
  * Support for Neutron server Liberty release.
  * Add new parameters that were added to Neutron NSX plugin during Liberty release.
  * Support of Fuel `component registry feature
    <https://blueprints.launchpad.net/fuel/+spec/component-registry>`_.
    Plugin is shown as separate item at network step of cluster creation
    wizard.
  * Plugin no longer ships customized python-nova package. All needed
    functionality for NSX support is available in python-nova Liberty package.
  * Plugin installation process takes less time, because it does not need restart
    docker containers.
  * Setting 'Cluster ModRef IDs for OpenStack VMs' was removed.
    Plugin automatically fetches cluster names that present on VMware tab and
    queries vCenter to get MoRef ID.  When new compute-vmware node is added and
    vSphere clusters gets assigned to it, plugin updates Neutron configuration
    file and restarts it.
  * Enable Neutron load balancer functionality and configure Horizon UI panel
    for LBaaS.
  * Create Neutron networks in admin tenant during deployment process.
  * Documentation improvements.

Release notes for Fuel NSXv plugin 1.2.0:

  * Fix bug `LP1527594 <https://bugs.launchpad.net/fuel/+bug/1527594>`_.
  * Provide python script that can restore cluster restrictions.
  * Documentation improvements.
