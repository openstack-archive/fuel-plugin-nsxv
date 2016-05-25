notice('fuel-plugin-nsxv: nsxv-config.pp')

include ::nsxv::params

$settings = hiera($::nsxv::params::plugin_name)
$roles    = hiera('roles')

if $settings['nsxv_metadata_initializer'] {
  $neutron_config         = hiera_hash('neutron_config')
  $metadata_shared_secret = $neutron_config['metadata']['metadata_proxy_shared_secret']
  $nova_metadata_ips      = get_nova_metadata_ip($settings['nsxv_metadata_listen'])

  if $settings['nsxv_mgt_reserve_ip'] {
    prepare_network_config(hiera('network_scheme'))
    $network_metadata = hiera('network_metadata')
    $mgt_ip           = $network_metadata['vips']['nsxv_metadataproxy_ip']['ipaddr']
    $mgt_netmask      = get_network_role_property('mgmt/vip', 'netmask')
    $mgt_gateway      = hiera('management_vrouter_vip')
  } else {
    $mgt_ip      = $settings['nsxv_mgt_net_proxy_ips']
    $mgt_netmask = $settings['nsxv_mgt_net_proxy_netmask']
    $mgt_gateway = $settings['nsxv_mgt_net_default_gateway']
  }

  class { '::nsxv':
    nova_metadata_ips      => $nova_metadata_ips,
    nova_metadata_port     => $::nsxv::params::nova_metadata_port,
    metadata_shared_secret => $metadata_shared_secret,
    mgt_ip                 => $mgt_ip,
    mgt_netmask            => $mgt_netmask,
    mgt_gateway            => $mgt_gateway,
    neutron_url_timeout    => $::nsxv::params::neutron_url_timeout,
    settings               => $settings,
    roles                  => $roles,
  }
} else {
  class { '::nsxv':
    neutron_url_timeout => $::nsxv::params::neutron_url_timeout,
    settings            => $settings,
    roles               => $roles,
  }
}
