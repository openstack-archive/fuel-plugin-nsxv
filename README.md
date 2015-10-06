Fuel NSXv plugin
================

Fuel NSXv plugin enables OpenStack deployment which utilizes vCenter with
installed and configured VMware NSXv network virtualization software.

See doc/ directory for documentation.

To build HTML variant of documentation you need to install sphinx document
generator, easiest way to do this is to use doc/requirements.txt.

  $ pip install -r doc/requirements.txt
  $ cd doc/source
  $ make html

After that you can start exploring documentation in doc/source/_build/html/ directory.
