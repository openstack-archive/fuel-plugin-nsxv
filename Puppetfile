#!/usr/bin/env ruby
#^syntax detection
# See https://github.com/bodepd/librarian-puppet-simple for additional docs
#
# Important information for fuel-library:
# With librarian-puppet-simple you *must* remove the existing folder from the
# repo prior to trying to run librarian-puppet as it will not remove the folder
# for you and you may run into some errors.

# Pull in puppetlabs-stdlib
mod 'stdlib',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppetlabs-stdlib.git',
    :ref => '4.9.0'

# Pull in puppet-neutron
mod 'neutron',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppet-neutron.git',
    :ref => 'stable/mitaka'

# Pull in puppet-nova
mod 'nova',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppet-nova.git',
    :ref => 'stable/mitaka'

# Pull in puppetlabs-inifile
mod 'inifile',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppetlabs-inifile.git',
    :ref => '1.4.2'

# Pull in puppet-openstacklib
mod 'openstacklib',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppet-openstacklib.git',
    :ref => 'stable/mitaka'

# Pull in puppet-keystone
mod 'keystone',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppet-keystone.git',
    :ref => 'stable/mitaka'

# TODO: need l23network(use cidr_to_netmask function)
