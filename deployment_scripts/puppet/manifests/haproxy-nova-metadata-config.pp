notice('fuel-plugin-nsxv: haproxy-nova-metadata-config.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  class { 'nsxv::haproxy_nova_metadata_config': }
}
