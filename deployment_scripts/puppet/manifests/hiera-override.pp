notice('fuel-plugin-nsxv: hiera-override.pp')

include ::nsxv::params

class { '::nsxv::hiera_override':
  plugin_name => $::nsxv::params::plugin_name,
}
