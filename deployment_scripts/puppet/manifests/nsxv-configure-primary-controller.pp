notice('fuel-plugin-nsxv: nsxv-configure-primary-controller.pp')

include ::nsxv::params
include ::neutron::db::sync
include ::neutron::params

$settings = hiera($::nsxv::params::plugin_name)
$metadata_initializer = $settings['nsxv_metadata_initializer']

nsx_config { "${::nsxv::params::plugin_name}/metadata_initializer": value => $metadata_initializer }

# need stop for safely upsate db if neutron-server runnnig
service { 'neutron-server-stop':
  ensure     => 'stopped',
  name       => $::neutron::params::server_service,
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
}

Nsx_config<||> ~> Exec['neutron-db-sync']
Service['neutron-server-stop'] -> Exec['neutron-db-sync']
