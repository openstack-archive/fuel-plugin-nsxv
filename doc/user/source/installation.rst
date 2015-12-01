Installation
============

#. Download plugin .rpm package from the Fuel Plugin Catalog.

#. Upload package to Fuel master node.

#. Install the plugin with *fuel* command line tool:

   .. code-block:: bash

    [root@nailgun ~] fuel plugins --install nsxv-1.0-1.0.0-1.noarch.rpm


   Installation process may take up to 1-2 minutes depending on hardware
   specification of your Fuel Master node, because plugin has to update database
   and restart docker containers.

#. Verify that the plugin is installed successfully:

  .. code-block:: bash

    [root@nailgun ~] fuel plugins
    id | name | version | package_version
    ---|------|---------|----------------
    1  | nsxv | 1.0.0   | 3.0.0

After installation plugin can be used for new OpenStack clusters, it is not
possible to enable plugin on deployed clusters.

Uninstallation
--------------

Before uninstalling plugin be sure that there no environments left that use the
plugin, otherwise it is not possible to uninstall it.

To uninstall plugin run following:

.. code-block:: bash

   [root@nailgun ~] fuel plugins --remove nsxv==1.0.0

During installation plugin changes Fuels database content.  It removes
restriction that forbids configuring vCenter with Neutron.  After plugin gets
uninstalled it is possible to configure inoperable configuration of cluster.
To prevent this situation execute *restore_db.py* script that comes with plugin
in *nailgun* docker container.  This action is not done automatically on plugin
uninstallation, because there are might be another plugin that also rely on
absence of restriction.

.. code-block:: bash

   [root@nailgun ~] dockerctl nailgun
   [root@nailgun ~] python /var/www/nailgun/plugins/nsxv-1.1/restore_db.py
