Release notes
=============

Release notes for Fuel NSXv plugin 3.0.1:

  * Plugin is compatible with Fuel 9.1.

Release notes for Fuel NSXv plugin 3.0.0:

  * Plugin is compatible with Fuel 9.0.
  * Plugin settings were moved to the Networks tab.
  * Roles that are not applicable to the environment with the plugin are hidden.
  * Novas timeout of HTTP requests to Neutron was increased up to 900 seconds.
    On a big amount of requests, neutron may be busy for a long period of time.
  * User can assign nova-api-metadata to listen OpenStack public or management
    network.
  * LBaaS v2 support is configured by default.
  * Troubleshooting section was added to plugin guide.
  * The plugin supports searching vCenter clusters name across a given data center
    hierarchy.
  * Added new parameters that were added to the Neutron NSX plugin during Mitaka release.

Release notes for Fuel NSXv plugin 2.0.0:

  * Plugin is compatible with Fuel 8.0.
  * Support for Neutron server Liberty release.
  * Added new parameters that were added to Neutron NSX plugin during Liberty release.
  * Support of Fuel `component registry feature
    <https://blueprints.launchpad.net/fuel/+spec/component-registry>`_.
    Plugin is shown as separate item at network step of cluster creation
    wizard.
  * Plugin no longer ships customized python-nova package. All needed
    functionality for NSX support is available in python-nova Liberty package.
  * Plugin installation process takes less time, because it does not need to restart
    docker containers.
  * Setting 'Cluster MoRef IDs for OpenStack VMs' was removed.
    Plugin automatically fetches cluster names that present on VMware tab and
    queries vCenter to get MoRef ID. When a new compute-vmware node is added and
    vSphere clusters gets assigned to it, the plugin updates the Neutron configuration
    file and restarts it.
  * Enable Neutron load balancer functionality and configure Horizon UI panel
    for LBaaS.
  * TestVM-VMDK image is overridden by the plugin with TinyCoreLinux image.
  * Fix bug `LP1519916 <https://bugs.launchpad.net/fuel-plugins/+bug/1519916>`_.
  * Create Neutron networks in admin tenant during deployment process.
  * Documentation improvements.

Release notes for Fuel NSXv plugin 1.2.0:

  * Fix bug `LP1527594 <https://bugs.launchpad.net/fuel/+bug/1527594>`_.
  * Provide python script that can restore cluster restrictions.
  * Documentation improvements.
