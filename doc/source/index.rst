.. Fuel NSXv plugin documentation master file

Welcome to Fuel NSXv plugin's documentation!
============================================

Fuel NSXv plugin allows you to deploy OpenStack cluster which can use
pre-existing vSphere infrastructure with NSX network virtualization platform.

Plugin installs Neutron NSX core plugin and allows logical network equipment
(routers, networks) to be created as NSX entities.

Plugin version 1.0.0 is compatible with Fuel 7.0.

Plugin can work with VMware NSX 6.1.3, 6.1.4.

Through documentation we use term "NSX" and "NSXv" interchangeably, both of
these term refer to `VMware NSX virtualized network platform
<https://www.vmware.com/products/nsx>`_.

Documentation contents:

.. toctree::
   :maxdepth: 2

   build
   installation
   environment
   configuration
   usage

Pre-built package of the plugin you can find in
`Fuel Plugin Catalog <https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins>`_.
