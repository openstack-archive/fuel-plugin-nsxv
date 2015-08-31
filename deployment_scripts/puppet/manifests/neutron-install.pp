notice('fuel-plugin-nsxv: neutron-install.pp')

include ::nsxv::params
include ::neutron::params

if ($::neutron::params::server_package) {
  # Debian platforms
  Package<| title == 'neutron-server' |> ~> Exec['neutron-db-sync-nsxv']
} else {
  # RH platforms
  Package<| title == 'neutron' |> ~> Exec['neutron-db-sync-nsxv']
}

exec { 'neutron-db-sync-nsxv':
  command     => "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file ${::nsxv::params::nsxv_config_dir}/nsx.ini upgrade head",
  path        => '/usr/bin',
  before      => Service['neutron-server'],
  subscribe   => Neutron_config['database/connection'],
  refreshonly => true,
  tries       => 10,
  try_sleep   => 20,
}
Neutron_config<||> ~> Exec['neutron-db-sync-nsxv']

class { 'openstack::network':
  network_provider    => 'neutron',
  agents              => [],
  ha_agents           => 'slave', # workaround in order to class '::neutron::server' not sync db
  verbose             => true,
  debug               => $::nsxv::params::debug,
  use_syslog          => $::nsxv::params::use_syslog,
  use_stderr          => $::nsxv::params::use_stderr,
  syslog_log_facility => $::nsxv::params::syslog_log_facility_neutron,

  neutron_server        => true,
  neutron_server_enable => true,
  neutron_db_uri        => $::nsxv::params::neutron_db_uri,
  nova_neutron          => true,
  base_mac              => undef,
  core_plugin           => $::nsxv::params::core_plugin,
  service_plugins       => [],
  net_mtu               => undef,
  network_device_mtu    => undef,
  bind_host             => $::nsxv::params::neutron_local_address_for_bind,
  dvr                   => false,
  l2_population         => false,
  service_workers       => $::nsxv::params::service_workers,

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
  queue_provider  => $::nsxv::params::queue_provider,
  amqp_hosts      => $::nsxv::params::amqp_hosts,

  amqp_user       => $::nsxv::params::rabbit_hash['user'],
  amqp_password   => $::nsxv::params::rabbit_hash['password'],

  # keystone
  admin_password    => $::nsxv::params::neutron_user_password,
  auth_url          => "http://${::nsxv::params::service_endpoint}:35357/v2.0",
  identity_uri      => "http://${::nsxv::params::service_endpoint}:35357",
  neutron_url       => "http://${::nsxv::params::neutron_endpoint}:9696",
  admin_tenant_name => $::nsxv::params::keystone_tenant,
  admin_username    => $::nsxv::params::keystone_user,
  region            => $::nsxv::params::region,

  # Ceilometer notifications
  ceilometer => $::nsxv::params::ceilometer_hash['enabled'],

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
  nova_admin_username    => $::nsxv::params::nova_hash['user'],
  nova_admin_tenant_name => $::nsxv::params::nova_hash['tenant'],
  nova_admin_password    => $::nsxv::params::nova_hash['user_password'],
  nova_url               => "http://${::nsxv::params::nova_endpoint}:8774/v2",
}
