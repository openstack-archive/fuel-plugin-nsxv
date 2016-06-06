notice('fuel-plugin-nsxv: neutron-server-start.pp')

include ::neutron::params

service { 'neutron-server-start':
  ensure     => 'running',
  name       => $::neutron::params::server_service,
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
}

# Need to stop neutron-server for applying new settings after refresh_on/rexecute_on.
# For example applying new cluster_morefid settings if new compute-vmware role has been added
exec { 'neutron-server-stop':
  path     => '/usr/sbin:/usr/bin:/sbin:/bin',
  command  => "service ${::neutron::params::server_service} stop",
  provider => 'shell',
  onlyif   => "service ${::neutron::params::server_service} status|grep -q running",
}

include ::nsxv::params

neutron_config {
  'DEFAULT/core_plugin':                value => $::nsxv::params::core_plugin;
  'DEFAULT/service_plugins':            value => $::nsxv::params::service_plugins;
  'service_providers/service_provider': value => $::nsxv::params::service_providers;
}

Neutron_config<||> ~> Service['neutron-server-start']
Exec['neutron-server-stop'] -> Service['neutron-server-start']

if 'primary-controller' in hiera('roles') {
  include ::neutron::db::sync

  Exec['neutron-server-stop'] -> Exec['neutron-db-sync'] ~> Service['neutron-server-start']
  Neutron_config<||> ~> Exec['neutron-db-sync']

  $neutron_config         = hiera_hash('neutron_config')
  $management_vip         = hiera('management_vip')
  $service_endpoint       = hiera('service_endpoint', $management_vip)
  $ssl_hash               = hiera_hash('use_ssl', {})
  $internal_auth_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
  $internal_auth_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [$service_endpoint])
  $identity_uri           = "${internal_auth_protocol}://${internal_auth_address}:5000"
  $auth_api_version       = 'v2.0'
  $auth_url               = "${identity_uri}/${auth_api_version}"
  $auth_password          = $neutron_config['keystone']['admin_password']
  $auth_user              = pick($neutron_config['keystone']['admin_user'], 'neutron')
  $auth_tenant            = pick($neutron_config['keystone']['admin_tenant'], 'services')
  $auth_region            = hiera('region', 'RegionOne')
  $auth_endpoint_type     = 'internalURL'

  exec { 'waiting-for-neutron-api':
    environment => [
      "OS_TENANT_NAME=${auth_tenant}",
      "OS_USERNAME=${auth_user}",
      "OS_PASSWORD=${auth_password}",
      "OS_AUTH_URL=${auth_url}",
      "OS_REGION_NAME=${auth_region}",
      "OS_ENDPOINT_TYPE=${auth_endpoint_type}",
    ],
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    tries       => '30',
    try_sleep   => '15',
    command     => 'neutron net-list --http-timeout=4 2>&1 > /dev/null',
    provider    => 'shell',
    subscribe   => Service['neutron-server-start'],
    refreshonly => true,
  }

  $settings      = hiera($::nsxv::params::plugin_name)
  $nsxv_ip       = $settings['nsxv_manager_host']
  $nsxv_user     = $settings['nsxv_user']
  $nsxv_password = $settings['nsxv_password']
  $datacenter_id = $settings['nsxv_datacenter_moid']

  # We can not rely on NSX Manager response regarding readiness of metadata router.
  # Seems that NSX Manager responses with deployedStatus true, but in fact metadata
  # router serve requests and neutron-server on secondary controller may fail with
  # metadata initialization step (unrecoverable error).
  # Ten seconds should be enough even for very loaded environment.
  exec { 'wait-for-metadata-router':
    exec    => "sleep 10",
    path    => "/bin:/usr/bin",
    require => [Service['neutron-server-start'],Exec['waiting-for-neutron-api']],
  }
}
