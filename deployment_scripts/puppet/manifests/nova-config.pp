notice('fuel-plugin-nsxv: nova-config.pp')

include ::nsxv::params
include ::nova::params

service { 'nova-api':
  ensure => 'running',
  name   => $::nova::params::api_service_name,
}

nova_config { 'neutron/service_metadata_proxy': value => 'True' }
nova_config { 'neutron/metadata_proxy_shared_secret': value => "${::nsxv::params::neutron_metadata_proxy_secret}" }
Nova_config<| |> ~> Service['nova-api']
