Fuel NSXv plugin
================

Fuel NSXv plugin enables OpenStack deployment which utilizes vCenter with
installed and configured VMware NSXv network virtualization software.

Supported features:
- VM port provisioning
- Security groups

How to build plugin:

* Install fuel plugin builder:

..
  pip install fuel-plugin-builder

* Clone plugin source repository

..
  git clone https://github.com/stackforge/fuel-plugin-nsxv

  cd fuel-plugin-nsxv/

  fpb --build .

Installation
============

* Upload the plugin to Fuel master node

* Install the plugin using Fuel command line client:

..
  fuel plugins --install nsxv-1.0-1.0.0-1.noarch.rpm
