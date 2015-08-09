class nsxv::nova_config (
  $metadata_ha_conf = '/etc/haproxy/conf.d/060-nova-metadata-api.cfg',
  $nova_conf = '/etc/nova/nova.conf',
) {
  include ::nova::params

  $roles = hiera('roles')

  $vcenter_hash    = hiera('vcenter_hash')
  $vcenter_settings = $vcenter_hash['computes']

  $neutron_config = hiera_hash('quantum_settings')
  $neutron_metadata_proxy_secret = $neutron_config['metadata']['metadata_proxy_shared_secret']
  $nova_parameters = {
    'neutron/service_metadata_proxy' => { value => 'True' },
    'neutron/metadata_proxy_shared_secret' => { value => "${neutron_metadata_proxy_secret}" }
  }

  if 'primary-controller' in $roles or 'controller' in $roles {
    include ::openstack::ha::haproxy_restart

    $public_vip = hiera('public_vip')

    $api_service_name = $::nova::params::api_service_name
    $cert_service_name = $::nova::params::cert_service_name
    $conductor_service_name = $::nova::params::conductor_service_name
    $scheduler_service_name = $::nova::params::scheduler_service_name

    file_line { 'metadat_public_listen':
      path => $metadata_ha_conf,
      after => 'listen nova-metadata-api',
      line => "  bind ${$public_vip}:8775",
      notify => Exec['haproxy-restart'],
    }
    service { [$api_service_name,$cert_service_name,$conductor_service_name,$scheduler_service_name]:
      ensure => 'running',
    }

    Nova_config<| |> ~> Service[$api_service_name,$cert_service_name,$conductor_service_name,$scheduler_service_name]
    Nsxv::Delete_line<| |> ~> Service[$api_service_name,$cert_service_name,$conductor_service_name,$scheduler_service_name]
  } elsif 'compute-vmware' in $roles {
    $management_vip            = hiera('management_vip')
    $service_endpoint          = hiera('service_endpoint')
    $neutron_endpoint          = hiera('neutron_endpoint', $management_vip)
    $neutron_admin_username    = pick($neutron_config['keystone']['admin_user'], 'neutron')
    $neutron_admin_password    = $neutron_config['keystone']['admin_password']
    $neutron_admin_tenant_name = pick($neutron_config['keystone']['admin_tenant'], 'services')
    $neutron_admin_auth_url    = "http://${service_endpoint}:35357/v2.0"
    $neutron_url               = "http://${neutron_endpoint}:9696"
    $region                    = hiera('region', 'RegionOne')

    class {'nova::network::neutron':
      neutron_admin_password    => $neutron_admin_password,
      neutron_admin_tenant_name => $neutron_admin_tenant_name,
      neutron_region_name       => $region,
      neutron_admin_username    => $neutron_admin_username,
      neutron_admin_auth_url    => $neutron_admin_auth_url,
      neutron_url               => $neutron_url,
      neutron_ovs_bridge        => '',
    }
    Nsxv::Delete_line<| |> { require => Class['nova::network::neutron'] }
  }

  nsxv::delete_line { ['network_manager','public_interface','force_snat_range','flat_network_bridge','flat_injected','flat_interface']:
    path => $nova_conf,
  }

  create_resources(nova_config, $nova_parameters)
  create_resources(nsxv::define_vmware_compute, parse_vcenter_settings($vcenter_settings))
  Nova_config<| |> ~> Service<| tag == 'vcenter_compute' |>
  Nsxv::Delete_line<| |> ~> Service<| tag == 'vcenter_compute' |>
}

define nsxv::delete_line (
  $line = $name,
  $path = undef,
) {
  $file_name = basename($path)
  exec { "delete_${line}_from_${file_name}":
    path => '/usr/bin:/usr/sbin:/bin',
    command => "sed -ri '/^\s*${line}.*$/d' $path",
    onlyif => "grep -E '^\s*${line}.*$' $path 1>/dev/null",
    provider => shell,
    tries       => 3,
    try_sleep   => 10,
  }
}

define nsxv::define_vmware_compute (
  $availability_zone_name,
  $vc_cluster,
  $vc_host,
  $vc_user,
  $vc_password,
  $service_name,
  $target_node,
  $datastore_regex = undef,
){
  $uid = hiera('uid')
  $current_node = "node-$uid"
  $roles = hiera('roles')

  if ($target_node == 'controllers' and ('primary-controller' in $roles or 'controller' in $roles)) {
    service { "p_nova_compute_vmware_${availability_zone_name}-${service_name}":
      ensure => running,
      enable => true,
      provider => 'pacemaker',
      tag =>  'vcenter_compute',
    }
  } elsif ($target_node == $current_node and 'compute-vmware' in $roles ) {
    service { 'nova-compute':
      ensure => running,
      name   => $::nova::params::compute_service_name,
      enable => true,
      tag =>  'vcenter_compute',
    }
  }
}
