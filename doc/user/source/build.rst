How to build the plugin
=======================

To build the plugin you first need to install fuel-plugin-build 4.0.0[1_]

.. code-block:: bash

  $ pip install fuel-plugin-builder==4.0.0

After that you can build plugin:

.. code-block:: bash

  $ git clone https://git.openstack.org/openstack/fuel-plugin-nsxv

  $ cd fuel-plugin-nsxv/

  $ fpb --build .

fuel-plugin-builder will produce .rpm package of the plugin which you need to upload
to Fuel master node:

.. code-block:: bash

  $ ls nsxv-*.rpm

  nsxv-2.0-2.0.0-1.noarch.rpm

.. [1] https://pypi.python.org/pypi/fuel-plugin-builder/4.0.0
