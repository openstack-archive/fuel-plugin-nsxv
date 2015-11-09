notice('fuel-plugin-nsxv: compute_vmware_nova_config.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  class { '::nsxv::compute_vmware_nova_config': }
}
