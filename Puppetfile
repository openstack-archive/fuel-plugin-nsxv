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

# Pull in puppetlabs-concat
mod 'concat',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppetlabs-concat.git',
    :ref => '1.2.3'

# Pull in puppet-neutron
mod 'neutron',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppet-neutron.git',
    :ref => '7.0.0-mos-rc6'

# Pull in puppet-nova
mod 'nova',
    :git => 'https://review.fuel-infra.org/p/puppet-modules/puppet-nova.git',
    :ref => '7.0.0-mos-rc2'
