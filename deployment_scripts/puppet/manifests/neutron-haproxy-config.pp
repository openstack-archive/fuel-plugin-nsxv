notice('fuel-plugin-nsxv: neutron-haproxy-config.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  class { '::nsxv::neutron_haproxy_config': }
}
