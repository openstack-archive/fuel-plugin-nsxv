class nsxv::nova_config (
  $metadta_ha_conf = '/etc/haproxy/conf.d/060-nova-metadata-api.cfg',
  $nova_packages = ['python-nova'],
  $nova_services = ['','','',]
) {
  include ::nova::params
  include ::openstack::ha::haproxy_restart

  $neutron_config = hiera_hash('quantum_settings')
  $neutron_metadata_proxy_secret = $neutron_config['metadata']['metadata_proxy_shared_secret']
  $nova_parameters = {
    'neutron/service_metadata_proxy' => { value => 'True' },
    'neutron/metadata_proxy_shared_secret' => { value => "${neutron_metadata_proxy_secret}" }
  }

  package { $nova_packages:
      ensure => latest,
  }

  $public_vip = hiera('public_vip')

  file_line { 'metadat_public_listen':
    path => $metadta_ha_conf,
    after => 'listen nova-metadata-api',
    line => "  bind ${$public_vip}:8775",
    notify => Exec['haproxy-restart'],
  }

  service { 'nova-api':
    ensure => 'running',
    name   => $::nova::params::api_service_name,
  }

  create_resources(nova_config, $nova_parameters)
  Nova_config<| |> ~> Service['nova-api']
}
