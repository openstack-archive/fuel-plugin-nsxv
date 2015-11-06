notice('MODULAR: openstack-network-controller.pp(fuel-plugin-nsxv patch)')

$core_plugin = 'vmware_nsx.neutron.plugins.vmware.plugin.NsxVPlugin'
$policy_file = '/etc/neutron/policy.d/nsxv.json'

$neutron_config  = hiera_hash('quantum_settings')
$rabbit_hash     = hiera_hash('rabbit_hash', {})
$ceilometer_hash = hiera('ceilometer',{})
$nova_hash       = hiera_hash('nova', {})
$network_scheme  = hiera('network_scheme', {})

prepare_network_config($network_scheme)

# Neutron DB settings
$neutron_db_password = $neutron_config['database']['passwd']
$neutron_db_user     = pick($neutron_config['database']['user'], 'neutron')
$neutron_db_name     = pick($neutron_config['database']['name'], 'neutron')
$neutron_db_host     = pick($neutron_config['database']['host'], hiera('database_vip'))
$neutron_db_uri      = "mysql://${neutron_db_user}:${neutron_db_password}@${neutron_db_host}/${neutron_db_name}?&read_timeout=60"

# Neutron Keystone settings
$neutron_user_password = $neutron_config['keystone']['admin_password']
$keystone_user         = pick($neutron_config['keystone']['admin_user'], 'neutron')
$keystone_tenant       = pick($neutron_config['keystone']['admin_tenant'], 'services')

# base
$neutron_local_address_for_bind = get_network_role_property('neutron/api', 'ipaddr') # prepare_network_config need
$region                         = hiera('region', 'RegionOne')
$management_vip                 = hiera('management_vip')
$service_workers                = pick($neutron_config['workers'], min(max($::processorcount, 2), 16))

# endpoints
$service_endpoint  = hiera('service_endpoint')
$nova_endpoint     = hiera('nova_endpoint', $management_vip)
$neutron_endpoint  = hiera('neutron_endpoint', $management_vip)

# logs
$debug                        = hiera('debug', true)
$use_syslog                   = hiera('use_syslog', true)
$use_stderr                   = hiera('use_stderr', false)
$syslog_log_facility_neutron  = hiera('syslog_log_facility_neutron', 'LOG_LOCAL4')

# Queue settings
$queue_provider  = hiera('queue_provider', 'rabbitmq')
$amqp_hosts      = split(hiera('amqp_hosts', ''), ',')

case hiera('nsxv_fuel_version') {
  '7.0': {
      $auth_url = "http://${service_endpoint}:35357/v2.0"
  }
  default: {
      $auth_url = "http://${service_endpoint}:5000"
  }
}

class { 'l23network' :
  use_ovs => false
}

include ::nova::params
service { 'nova-api':
  ensure => 'running',
  name   => $::nova::params::api_service_name,
}
Nova_config<| |> ~> Service['nova-api']

class { 'openstack::network':
  network_provider    => 'neutron',
  agents              => [],
  ha_agents           => false,
  verbose             => true,
  debug               => $debug,
  use_syslog          => $use_syslog,
  use_stderr          => $use_stderr,
  syslog_log_facility => $syslog_log_facility_neutron,

  neutron_server        => true,
  neutron_server_enable => true,
  neutron_db_uri        => $neutron_db_uri,
  nova_neutron          => true,
  base_mac              => undef,
  core_plugin           => $core_plugin,
  service_plugins       => [],
  net_mtu               => undef,
  network_device_mtu    => undef,
  bind_host             => $neutron_local_address_for_bind,
  dvr                   => false,
  l2_population         => false,
  service_workers       => $service_workers,

  #ovs
  mechanism_drivers    => undef,
  local_ip             => undef,
  bridge_mappings      => undef,
  network_vlan_ranges  => undef,
  enable_tunneling     => undef,
  tunnel_id_ranges     => undef,
  vni_ranges           => undef,
  tunnel_types         => undef,
  tenant_network_types => undef,

  floating_bridge      => undef,

  #Queue settings
  queue_provider  => $queue_provider,
  amqp_hosts      => $amqp_hosts,

  amqp_user       => $rabbit_hash['user'],
  amqp_password   => $rabbit_hash['password'],

  # keystone
  admin_password    => $neutron_user_password,
  auth_url          => $auth_url,
  identity_uri      => "http://${service_endpoint}:35357",
  neutron_url       => "http://${neutron_endpoint}:9696",
  admin_tenant_name => $keystone_tenant,
  admin_username    => $keystone_user,
  region            => $region,

  # Ceilometer notifications
  ceilometer => $ceilometer_hash['enabled'],

  #metadata
  shared_secret     => undef,
  metadata_ip       => undef,
  isolated_metadata => undef,

  #nova settings
  private_interface      => undef,
  public_interface       => undef,
  fixed_range            => undef,
  floating_range         => undef,
  network_manager        => undef,
  network_config         => undef,
  create_networks        => undef,
  num_networks           => undef,
  network_size           => undef,
  nameservers            => undef,
  enable_nova_net        => undef,
  nova_admin_username    => $nova_hash['user'],
  nova_admin_tenant_name => $nova_hash['tenant'],
  nova_admin_password    => $nova_hash['user_password'],
  nova_url               => "http://${nova_endpoint}:8774/v2",
}
file { $policy_file:
  ensure  => file,
  source  => 'file:///etc/puppet/files/policy.json',
  mode    => '0644',
  require => Class['openstack::network'],
  replace => true,
}
