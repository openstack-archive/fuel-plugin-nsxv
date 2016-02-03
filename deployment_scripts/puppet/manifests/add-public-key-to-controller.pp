notice('fuel-plugin-nsxv: add-public-key-to-controller.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
    class { '::nsxv::add_public_key_to_controller': }
}
