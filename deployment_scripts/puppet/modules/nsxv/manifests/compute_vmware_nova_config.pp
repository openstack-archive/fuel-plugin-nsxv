class nsxv::compute_vmware_nova_config {
  include ::nova::params
  include ::nsxv::params

  $neutron_config = hiera_hash('neutron_config')
  $neutron_metadata_proxy_secret = $neutron_config['metadata']['metadata_proxy_shared_secret']
  $nova_parameters = {
    'neutron/service_metadata_proxy'       => { value => 'True' },
    'neutron/metadata_proxy_shared_secret' => { value => $neutron_metadata_proxy_secret }
  }
  $management_vip             = hiera('management_vip')
  $service_endpoint           = hiera('service_endpoint', $management_vip)
  $admin_password             = try_get_value($neutron_config, 'keystone/admin_password')
  $admin_tenant_name          = try_get_value($neutron_config, 'keystone/admin_tenant', 'services')
  $admin_username             = try_get_value($neutron_config, 'keystone/admin_user', 'neutron')
  $region_name                = hiera('region', 'RegionOne')
  $auth_api_version           = 'v2.0'
  $ssl_hash                   = hiera_hash('use_ssl', {})
  $admin_identity_protocol    = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
  $admin_identity_address     = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', [$service_endpoint, $management_vip])
  $neutron_internal_protocol  = get_ssl_property($ssl_hash, {}, 'neutron', 'internal', 'protocol', 'http')
  $neutron_endpoint           = get_ssl_property($ssl_hash, {}, 'neutron', 'internal', 'hostname', [hiera('neutron_endpoint', ''), $management_vip])
  $admin_identity_uri         = "${admin_identity_protocol}://${admin_identity_address}:35357"
  $admin_auth_url             = "${admin_identity_uri}/${auth_api_version}"
  $neutron_url                = "${neutron_internal_protocol}://${neutron_endpoint}:9696"

  class {'nova::network::neutron':
    neutron_admin_password    => $admin_password,
    neutron_admin_tenant_name => $admin_tenant_name,
    neutron_region_name       => $region_name,
    neutron_admin_username    => $admin_username,
    neutron_admin_auth_url    => $admin_auth_url,
    neutron_url               => $neutron_url,
    neutron_ovs_bridge        => '',
    neutron_url_timeout       => $::nsxv::params::neutron_url_timeout,
  }

  create_resources(nova_config, $nova_parameters)
}
