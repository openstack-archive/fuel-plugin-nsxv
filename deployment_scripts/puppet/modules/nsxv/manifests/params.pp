class nsxv::params {
  ### neutron-install.pp
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
  #$core_plugin                    = 'neutron.plugins.vmware.plugin.NsxVPlugin'
  $core_plugin                    = 'vmware_nsx.neutron.plugins.vmware.plugin.NsxVPlugin'
  $neutron_local_address_for_bind = get_network_role_property('neutron/api', 'ipaddr') # prepare_network_config need
  $region                         = hiera('region', 'RegionOne')
  $service_workers                = min(max($::processorcount, 2), 16)
  $management_vip                 = hiera('management_vip')
  
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

  ### disable-nova-network.pp
  $nova_network_service_name = 'p_vcenter_nova_network'
  $nova_network_config_dir = '/etc/nova/nova-network.d'
  $nova_network_config_ha = "${nova_network_config_dir}/nova-network-ha.conf"
  
  ### nova-config.pp
  $neutron_metadata_proxy_secret  = $neutron_config['metadata']['metadata_proxy_shared_secret']

  ### nsxv-config.pp 
  $nsxv_config_dir = '/etc/neutron/plugins/vmware'
  $neutron_plugn_config = '/etc/default/neutron-server'
}
