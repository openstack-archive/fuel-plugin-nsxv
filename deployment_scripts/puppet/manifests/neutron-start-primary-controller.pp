notice('fuel-plugin-nsxv: neutron-start-primary-controller.pp')

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

Exec['neutron-server-stop'] -> Service['neutron-server-start']

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
