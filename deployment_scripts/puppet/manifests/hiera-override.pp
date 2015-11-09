notice('fuel-plugin-nsxv: hiera-override.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  # Values are changed by pre_build_hook
  class { '::nsxv::hiera_override':
    plugin_name => 'NAME',
  }
}
