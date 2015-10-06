Installation
============

#. Download plugin .rpm package from the Fuel Plugin Catalog

#. Upload package to Fuel master node

#. Install the plugin with *fuel* command line tool

   .. code-block:: bash

    [root@nailgun ~] fuel plugins --install nsxv-1.0-1.0.0-1.noarch.rpm


   Installation process may take up to 1-2 minutes depending on hardware
   specification of your Fuel Master node, because plugin has to update database
   and restart docker containers.

#. Verify that the plugin is installed successfully

  .. code-block:: bash

    [root@nailgun ~] fuel plugins
    id | name | version | package_version
    ---|------|---------|----------------
    1  | nsxv | 1.0.0   | 3.0.0

After installation plugin can be used for new OpenStack clusters, it is not
possible to enable plugin on deployed clusters.
