notice('fuel-plugin-nsxv: neutron-server-start.pp')

$use_neutron = hiera('use_neutron', false)

if $use_neutron {
  include ::neutron::params

  $nsxv_config_file = '/etc/neutron/plugins/vmware/nsx.ini'

  service { 'neutron-server':
    ensure     => 'running',
    name       => $::neutron::params::server_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  neutron_config {
    'DEFAULT/core_plugin': value => 'vmware_nsx.plugin.NsxVPlugin';
    'DEFAULT/service_plugins': value => 'neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPlugin';
    'service_providers/service_provider': value => 'LOADBALANCER:VMWareEdge:neutron_lbaas.services.loadbalancer.drivers.vmware.edge_driver.EdgeLoadbalancerDriver:default';
  }
  Neutron_config<||> ~> Service['neutron-server']

  if 'primary-controller' in hiera('role') {
    Exec['neutron-db-sync'] ~> Service['neutron-server']
    Neutron_config<||> ~> Exec['neutron-db-sync']

    $neutron_config = hiera_hash('neutron_config')
    $management_vip     = hiera('management_vip')
    $service_endpoint   = hiera('service_endpoint', $management_vip)
    $auth_api_version   = 'v2.0'
    $identity_uri       = "http://${service_endpoint}:5000"
    $auth_url           = "${identity_uri}/${auth_api_version}"
    $auth_password      = $neutron_config['keystone']['admin_password']
    $auth_user          = pick($neutron_config['keystone']['admin_user'], 'neutron')
    $auth_tenant        = pick($neutron_config['keystone']['admin_tenant'], 'services')
    $auth_region        = hiera('region', 'RegionOne')
    $auth_endpoint_type = 'internalURL'

    exec { 'neutron-db-sync':
      command     => "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file ${nsxv_config_file} upgrade head",
      path        => '/usr/bin',
      refreshonly => true,
      logoutput   => on_failure,
      provider    => 'shell',
    }

    exec { 'waiting-for-neutron-api':
      environment => [
        "OS_TENANT_NAME=${auth_tenant}",
        "OS_USERNAME=${auth_user}",
        "OS_PASSWORD=${auth_password}",
        "OS_AUTH_URL=${auth_url}",
        "OS_REGION_NAME=${auth_region}",
        "OS_ENDPOINT_TYPE=${auth_endpoint_type}",
      ],
      path      => '/usr/sbin:/usr/bin:/sbin:/bin',
      tries     => '30',
      try_sleep => '4',
      command   => 'neutron net-list --http-timeout=4 2>&1 > /dev/null',
      provider  => 'shell',
      require   => Service['neutron-server'],
    }
  }
}
