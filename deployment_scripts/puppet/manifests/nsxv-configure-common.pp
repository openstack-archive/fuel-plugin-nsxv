notice('fuel-plugin-nsxv: nsxv-configure-common.pp')

include ::nsxv::params

$settings = hiera($::nsxv::params::plugin_name)

$ca_filename = try_get_value($settings['nsxv_ca_file'], 'name', '')
if empty($ca_filename) {
  $insecure = true # used in nsx.ini.erb
} else {
  $insecure = false
  $ca_certificate_content = $settings['nsxv_ca_file']['content']
  $ca_file = "${::nsxv::params::plugin_config_dir}/${ca_filename}"

  file { $ca_file:
    ensure  => present,
    content => $ca_certificate_content,
    require => File[$::nsxv::params::config_dirs],
  }
}

# FIXME(izinovik): should moved out of this file.
# fix [neutron]/timeout in nova.conf
nova_config { 'neutron/timeout': value => $neutron_url_timeout }

if $settings['nsxv_metadata_initializer'] {
  $neutron_config         = hiera_hash('neutron_config')
  $metadata_shared_secret = $neutron_config['metadata']['metadata_proxy_shared_secret'] # used in nsx.ini.erb
  $nova_metadata_ips      = get_nova_metadata_ip($settings['nsxv_metadata_listen'])

  $metadata_nova_client_cert_filename     = try_get_value($settings['nsxv_metadata_nova_client_cert'], 'name', '')
  $metadata_nova_client_priv_key_filename = try_get_value($settings['nsxv_metadata_nova_client_priv_key'], 'name', '')

  if empty($metadata_nova_client_cert_filename) and empty($metadata_nova_client_priv_key_filename) {
    $metadata_insecure = true # used in nsx.ini.erb
  } else {
    $metadata_insecure = false

    $metadata_nova_client_cert_content = $settings['nsxv_metadata_nova_client_cert']['content']
    $metadata_nova_client_cert_file    = "${nsxv_config_dir}/cert_${metadata_nova_client_cert_filename}"

    $metadata_nova_client_priv_key_content = $settings['nsxv_metadata_nova_client_priv_key']['content']
    $metadata_nova_client_priv_key_file    = "${nsxv_config_dir}/key_${metadata_nova_client_priv_key_filename}"

    file { $metadata_nova_client_cert_file:
      ensure  => present,
      content => $metadata_nova_client_cert_content,
      require => File[$::nsxv::params::config_dirs],
    }
    file { $metadata_nova_client_priv_key_file:
      ensure  => present,
      content => $metadata_nova_client_priv_key_content,
      require => File[$::nsxv::params::config_dirs],
      owner   => 'neutron',
      group   => 'neutron',
      mode    => '0600',
    }
  }

  if $settings['nsxv_metadata_listen'] == 'management' {
    # "nova metadata api" will be listened to management network
    prepare_network_config(hiera('network_scheme'))
    $network_metadata = hiera('network_metadata')
    $mgt_ip           = $network_metadata['vips']['nsxv_metadataproxy_ip']['ipaddr']
    $mgt_netmask      = get_network_role_property('mgmt/vip', 'netmask')
    $mgt_gateway      = hiera('management_vrouter_vip')
  } else {
    # otherwise "nova metadata api" will be listened to public network
    $mgt_ip      = $settings['nsxv_mgt_net_proxy_ips']
    $mgt_netmask = $settings['nsxv_mgt_net_proxy_netmask']
    $mgt_gateway = $settings['nsxv_mgt_net_default_gateway']
  }
}

$cluster_moid = get_vcenter_cluster_id($settings['nsxv_datacenter_moid']) # used in nsx.ini.erb

file { $::nsxv::params::config_dirs:
  ensure => directory
}

file { "${::nsxv::params::plugin_config_dir}/nsx.ini":
  ensure  => file,
  content => template("${::nsxv::params::plugin_name}/nsx.ini.erb"),
  require => File[$::nsxv::params::config_dirs],
}

file { '/etc/neutron/plugin.ini':
  ensure  => link,
  target  => "${::nsxv::params::plugin_config_dir}/nsx.ini",
  replace => true,
  require => File[$::nsxv::params::config_dirs]
}
