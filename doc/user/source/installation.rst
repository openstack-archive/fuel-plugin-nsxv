Installation
============

#. Download the plugin .rpm package from the `Fuel plugin catalog`_.

#. Upload the package to the Fuel master node.

#. Install the plugin with the ``fuel`` command-line tool:

   .. code-block:: bash

    [root@nailgun ~] fuel plugins --install nsxv-3.0-3.0.0-1.noarch.rpm


#. Verify that the plugin installation is successful:

  .. code-block:: bash

    [root@nailgun ~] fuel plugins
    id | name | version | package_version
    ---|------|---------|----------------
    1  | nsxv | 3.0.0   | 4.0.0

After the installation, the plugin can be used on new OpenStack clusters;
you cannot enable the plugin on the deployed clusters.

Uninstallation
--------------

Before uninstalling the plugin, ensure there no environments left that use the
plugin, otherwise the uninstallation is not possible.

To uninstall the plugin, run following:

.. code-block:: bash

   [root@nailgun ~] fuel plugins --remove nsxv==3.0.0

.. _Fuel plugin catalog: https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins
