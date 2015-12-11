How to build the plugin
=======================

To build the plugin you first need to install fuel-plugin-build 4.0.0[1_]

.. code-block:: bash

  $ pip install fuel-plugin-builder==4.0.0

After that you can build the plugin:

.. code-block:: bash

  $ git clone https://git.openstack.org/openstack/fuel-plugin-nsxv

  $ cd fuel-plugin-nsxv/

puppet-librarian_ ruby package is required to installed. It is used to fetch
upstream fuel-library_ puppet modules that plugin use. It can be installed via
gem package manager:

.. code-block:: bash

  $ gem install puppet-librarian

.. code-block:: bash

  $ fpb --build .

fuel-plugin-builder will produce .rpm package of the plugin which you need to
upload to Fuel master node:

.. code-block:: bash

  $ ls nsxv-*.rpm

  nsxv-2.0-2.0.0-1.noarch.rpm

.. [1] https://pypi.python.org/pypi/fuel-plugin-builder/4.0.0
.. _puppet-librarian: https://librarian-puppet.com
.. _fuel-library: https://github.com/openstack/fuel-library
