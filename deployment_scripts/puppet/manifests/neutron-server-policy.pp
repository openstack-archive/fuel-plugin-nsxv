notice('fuel-plugin-nsxv: neutron-server-policy.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  class { '::nsxv::neutron_server_policy': }
}
