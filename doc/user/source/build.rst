How to build the plugin
=======================

To build the plugin you first need to install fuel-plugin-build 3.0.0[1_]

.. code-block:: bash

  $ pip install fuel-plugin-builder==3.0.0

After that you can build the plugin:

.. code-block:: bash

  $ git clone https://git.openstack.org/openstack/fuel-plugin-nsxv

  $ cd fuel-plugin-nsxv/

Now you need to fetch upstream puppet modules that plugin use:

.. code-block:: bash

  $ ./update_modules.sh

  $ fpb --build .

fuel-plugin-builder will produce .rpm package of the plugin which you need to upload
to Fuel master node:

.. code-block:: bash

  $ ls nsxv-*.rpm

  nsxv-1.0-1.0.0-1.noarch.rpm

.. [1] https://pypi.python.org/pypi/fuel-plugin-builder/3.0.0
