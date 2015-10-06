Usage
=====

Instances that you run in OpenStack cluster with vCenter and NSXv must have
VMware tools installed, otherwise there will be no connectivity.

The only way to create Distributed Router is to use neutron CLI tool:

.. code-block:: bash

  $ neutron router-create dvr --distributed True

