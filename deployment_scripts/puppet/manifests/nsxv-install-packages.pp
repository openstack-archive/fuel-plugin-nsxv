notice('fuel-plugin-nsxv: nsxv-install-packages.pp')

include ::nsxv::params

Package { ensure => latest }

package { $::nsxv::params::nsx_plugin_pkg: }
package { $::nsxv::params::lbaas_plugin_pkg: }
package { $::nsxv::params::test_image_pkg: }
