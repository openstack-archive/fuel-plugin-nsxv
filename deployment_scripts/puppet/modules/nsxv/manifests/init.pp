class nsxv (
  $nsxv_config_dir = '/etc/neutron/plugins/vmware',
  $neutron_plugin_name = 'python-vmware-nsx',
  $neutron_plugin_file = '/etc/neutron/plugin.ini',
) {

  $quantum_settings = hiera('quantum_settings')

  $settings = hiera('nsxv')

  # Do not remove unused variables: template nsx.ini.erb refers to them
  $nova_metadata_ips = hiera('public_vip')
  $nova_metadata_port = '8775'
  $metadata_shared_secret = $quantum_settings['metadata']['metadata_proxy_shared_secret']

  if ! $settings['nsxv_insecure'] {
    $ca_certificate_content = $settings['nsxv_ca_file']['content']
    $ca_file = "${nsxv_config_dir}/ca.pem"

    file { $ca_file:
      ensure  => present,
      content => $ca_certificate_content,
      require => Exec['nsxv_config_dir'],
    }
  }

  package { $neutron_plugin_name:
    ensure => latest,
  }

  $nsxv_config_dirs = [ '/etc/neutron', '/etc/neutron/plugins', '/etc/neutron/plugins/vmware' ]
  file { $nsxv_config_dirs:
    ensure => directory
  }

  file { "${nsxv_config_dir}/nsx.ini":
    ensure  => file,
    content => template("${module_name}/nsx.ini.erb"),
    require => File[$nsxv_config_dirs],
  }
  file { '/etc/default/neutron-server':
    ensure  => file,
    content => "CONF_ARG='--config-file ${neutron_plugin_file}'",
  }
  # need for work db_sync
  file { $neutron_plugin_file:
    ensure  => link,
    target  => "${nsxv_config_dir}/nsx.ini",
    replace => true,
    require => File[$nsxv_config_dirs]
  }
}
