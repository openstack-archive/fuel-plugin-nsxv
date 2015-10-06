Installation
============

Generated .rpm package you need to upload to Fuel master node.

Install the plugin with *fuel* command line tool:

.. code-block:: bash

  [root@nailgun ~] fuel plugins --install nsxv-1.0-1.0.0-1.noarch.rpm


Installation process may take up to 1-2 minutes depending on hardware
specification of your Fuel master node, because plugin have to update database
and restart docker containers.

After installation plugin can be used for new OpenStack clusters, it is not
possible to enable plugin on deployed clusters.
