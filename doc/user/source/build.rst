How to build the plugin from source
===================================

To build the plugin you first need to install fuel-plugin-builder_ 4.0.0

.. code-block:: bash

  $ pip install fuel-plugin-builder==4.1.0

After that you can build the plugin:

.. code-block:: bash

  $ git clone https://git.openstack.org/openstack/fuel-plugin-nsxv

  $ cd fuel-plugin-nsxv/

librarian-puppet_ ruby package is required to be installed. It is used to fetch
upstream fuel-library_ puppet modules that plugin use. It can be installed via
*gem* package manager:

.. code-block:: bash

  $ gem install librarian-puppet

or if you are using ubuntu linux - you can install it from the repository:

.. code-block:: bash

  $ apt-get install librarian-puppet

and build plugin:

.. code-block:: bash

  $ fpb --build .

fuel-plugin-builder will produce .rpm package of the plugin which you need to
upload to Fuel master node:

.. code-block:: bash

  $ ls nsxv-*.rpm

  nsxv-3.0-3.0.0-1.noarch.rpm

.. _fuel-plugin-builder: https://pypi.python.org/pypi/fuel-plugin-builder/4.0.0
.. _librarian-puppet: http://librarian-puppet.com
.. _fuel-library: https://github.com/openstack/fuel-library
