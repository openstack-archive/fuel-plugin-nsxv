class nsxv (
  $nsxv_config_dir = '/etc/neutron/plugins/vmware',
  $neutron_plugin_file = '/etc/neutron/plugin.ini',
  $neutron_plugin_name = 'python-vmware-nsx',
) {

  $quantum_settings = hiera('quantum_settings')

  $settings = hiera('nsxv')

  # Do not remove unused variables: template nsx.ini.erb refers to them
  $nova_metadata_ips = hiera('public_vip')
  $nova_metadata_port = '8775'
  $metadata_shared_secret = $quantum_settings['metadata']['metadata_proxy_shared_secret']

  $nsxv_config_dirs = [ '/etc/neutron', '/etc/neutron/plugins', '/etc/neutron/plugins/vmware' ]
  file { $nsxv_config_dirs:
    ensure => directory
  }

  if ! $settings['nsxv_insecure'] {
    $ca_certificate_content = $settings['nsxv_ca_file']['content']
    $ca_filename = $settings['nsxv_ca_file']['name']
    $ca_file = "${nsxv_config_dir}/${ca_filename}"

    file { $ca_file:
      ensure  => present,
      content => $ca_certificate_content,
      require => File[$nsxv_config_dirs],
    }
  }

  package { $neutron_plugin_name:
    ensure => latest,
  }

  file { "${nsxv_config_dir}/nsx.ini":
    ensure  => file,
    content => template("${module_name}/nsx.ini.erb"),
    require => File[$nsxv_config_dirs],
  }
  file { $neutron_plugin_file:
    ensure  => link,
    target  => "${nsxv_config_dir}/nsx.ini",
    replace => true,
    require => File[$nsxv_config_dirs]
  }
}
