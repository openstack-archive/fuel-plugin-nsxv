Installation
============

#. Download plugin .rpm package from the Fuel Plugin Catalog.

#. Upload package to Fuel master node.

#. Install the plugin with *fuel* command line tool:

   .. code-block:: bash

    [root@nailgun ~] fuel plugins --install nsxv-2.0-2.0.0-1.noarch.rpm


   Installation process may take up to 1-2 minutes depending on hardware
   specification of your Fuel Master node, because plugin has to update database
   and restart docker containers.

#. Verify that the plugin is installed successfully:

  .. code-block:: bash

    [root@nailgun ~] fuel plugins
    id | name | version | package_version
    ---|------|---------|----------------
    1  | nsxv | 2.0.0   | 4.0.0

After installation plugin can be used for new OpenStack clusters, it is not
possible to enable plugin on deployed clusters.

Uninstallation
--------------

Before uninstalling plugin be sure that there no environments left that use the
plugin, otherwise it is not possible to uninstall it.

To uninstall plugin run following:

.. code-block:: bash

   [root@nailgun ~] fuel plugins --remove nsxv==2.0.0
