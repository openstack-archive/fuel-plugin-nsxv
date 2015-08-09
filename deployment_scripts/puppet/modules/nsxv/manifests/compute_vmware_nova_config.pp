class nsxv::compute_vmware_nova_config (
) {
  include ::nova::params

  $neutron_config = hiera_hash('quantum_settings')
  $neutron_metadata_proxy_secret = $neutron_config['metadata']['metadata_proxy_shared_secret']
  $nova_parameters = {
    'neutron/service_metadata_proxy' => { value => 'True' },
    'neutron/metadata_proxy_shared_secret' => { value => "${neutron_metadata_proxy_secret}" }
  }

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

  create_resources(nova_config, $nova_parameters)
}
