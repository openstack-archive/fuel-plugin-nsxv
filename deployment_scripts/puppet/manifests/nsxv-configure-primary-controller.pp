notice('fuel-plugin-nsxv: nsxv-configure-primary-controller.pp')

include ::nsxv::params

$settings = hiera($::nsxv::params::plugin_name)

$metadata_initializer = $settings['nsxv_metadata_initializer']

nsx_config { "${::nsxv::params::plugin_name}/metadata_initializer": value => $metadata_initializer }

include ::neutron::db::sync

Nsx_config<||> ~> Exec['neutron-db-sync']
