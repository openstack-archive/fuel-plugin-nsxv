notice('fuel-plugin-nsxv: add-private-key-to-compute.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  class { '::nsxv::add_private_key_to_compute': }
}

