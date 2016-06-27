class nsxv (
  # Do not remove unused variables: template nsx.ini.erb refers to them
  $nsxv_config_dirs = [ '/etc/neutron', '/etc/neutron/plugins', '/etc/neutron/plugins/vmware' ],
  $nsxv_config_dir = '/etc/neutron/plugins/vmware',
  $nsx_plugin_name = 'python-vmware-nsx',
  $lbaas_plugin_name = 'python-neutron-lbaas',
  $neutron_url_timeout = '600',
  $settings,
  $roles,
  $nova_metadata_ips = '',
  $nova_metadata_port = '',
  $metadata_shared_secret = '',
  $mgt_ip = '',
  $mgt_netmask = '',
  $mgt_gateway = '',
) {

  $cluster_moid = get_vcenter_cluster_id($settings['nsxv_datacenter_moid'])

  $ca_filename = try_get_value($settings['nsxv_ca_file'],'name','')
  if empty($ca_filename) {
    $insecure = true # used in nsx.ini.erb template
  } else {
    $insecure = false
    $ca_certificate_content = $settings['nsxv_ca_file']['content']
    $ca_file = "${nsxv_config_dir}/${ca_filename}"

    file { $ca_file:
      ensure  => present,
      content => $ca_certificate_content,
      require => File[$nsxv_config_dirs],
    }
  }

  # we must explicitly disable metadata server initialization for all nodes except the primary-controller
  if 'primary-controller' in $roles {
    $metadata_initializer = $settings['nsxv_metadata_initializer']
  } else {
    $metadata_initializer = false
  }

  if !$settings['nsxv_metadata_insecure'] {
    $metadata_nova_client_cert_filename     = try_get_value($settings['nsxv_metadata_nova_client_cert'], 'name', '')
    $metadata_nova_client_priv_key_filename = try_get_value($settings['nsxv_metadata_nova_client_priv_key'], 'name', '')

    if !empty($metadata_nova_client_cert_filename) and !empty($metadata_nova_client_priv_key_filename) {
      $metadata_nova_client_cert_content = $settings['nsxv_metadata_nova_client_cert']['content']
      $metadata_nova_client_cert_file    = "${nsxv_config_dir}/cert_${metadata_nova_client_cert_filename}"

      $metadata_nova_client_priv_key_content = $settings['nsxv_metadata_nova_client_priv_key']['content']
      $metadata_nova_client_priv_key_file    = "${nsxv_config_dir}/key_${metadata_nova_client_priv_key_filename}"

      file { $metadata_nova_client_cert_file:
        ensure  => present,
        content => $metadata_nova_client_cert_content,
        require => File[$nsxv_config_dirs],
      }
      file { $metadata_nova_client_priv_key_file:
        ensure  => present,
        content => $metadata_nova_client_priv_key_content,
        require => File[$nsxv_config_dirs],
        owner   => 'neutron',
        group   => 'neutron',
        mode    => '0600',
      }
    }
  }

  package { $nsx_plugin_name:
    ensure => latest,
  }
  package { $lbaas_plugin_name:
    ensure => latest,
  }
  package { 'tcl-testvm':
    ensure => latest,
  }

  file { $nsxv_config_dirs:
    ensure => directory
  }

  file { "${nsxv_config_dir}/nsx.ini":
    ensure  => file,
    content => template("${module_name}/nsx.ini.erb"),
    require => File[$nsxv_config_dirs],
  }
  file { '/etc/neutron/plugin.ini':
    ensure  => link,
    target  => "${nsxv_config_dir}/nsx.ini",
    replace => true,
    require => File[$nsxv_config_dirs]
  }

  # fix [neutron]/timeout in nova.conf
  nova_config { 'neutron/timeout': value => $neutron_url_timeout }
}
