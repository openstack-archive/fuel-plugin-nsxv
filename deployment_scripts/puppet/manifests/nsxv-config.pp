notice('fuel-plugin-nsxv: nsxv-config.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  class { '::nsxv':
    plugin_name => 'NAME',
  }
}
