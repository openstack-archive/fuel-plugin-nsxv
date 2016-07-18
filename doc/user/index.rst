.. Fuel NSXv plugin documentation master file

Welcome to Fuel NSXv plugin's documentation!
============================================

The Fuel NSXv plugin allows you to deploy an OpenStack cluster which can use
a pre-existing vSphere infrastructure with the NSX network virtualization
platform.

The plugin installs the Neutron NSX core plugin and allows logical network
equipment (routers, networks) to be created as NSX entities.

The plugin supports VMware NSX 6.1.3, 6.1.4, 6.2.1.

Plugin versions:

* 3.x.x series is compatible with Fuel 9.0. Tests were performed on the plugin
  v3.0 with VMware NSX 6.2.0 and vCenter 5.5.

* 2.x.x series is compatible with Fuel 8.0. Tests were performed on the plugin
  v2.0 with  VMware NSX 6.2.0 and vCenter 5.5.

* 1.x.x series is compatible with Fuel 7.0. Tests were performed on the plugin
  v1.2 with VMware NSX 6.1.4 and vCenter 5.5.

This documentation uses the terms "NSX" and "NSXv" interchangeably; both of
these terms refer to `VMware NSX virtualized network platform
<https://www.vmware.com/products/nsx>`_.

The pre-built package of the plugin is in
`Fuel Plugin Catalog <https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins>`_.

Documentation contents
======================

.. toctree::
   :maxdepth: 2

   source/installation
   source/environment
   source/configuration
   source/limitations
   source/known-issues
   source/usage
   source/release-notes
   source/troubleshooting
   source/build
