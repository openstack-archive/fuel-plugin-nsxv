class nsxv (
  $nsxv_config_dir = '/etc/neutron/plugins/vmware',
  $neutron_plugin_file = '/etc/neutron/plugin.ini',
  $neutron_plugin_name = 'python-vmware-nsx',
) {

  $network_metadata = hiera('network_metadata')
  $quantum_settings = hiera('quantum_settings')

  $settings = hiera('nsxv')
  $nova_metadata_ips = $network_metadata['vips']['public']['ipaddr']
  $nova_metadata_port = '8775'
  $metadata_shared_secret = $quantum_settings['metadata']['metadata_proxy_shared_secret']

  if ! $settings['nsxv_insecure'] {
    $ca_certificate_content = $settings['nsxv_ca_file']['content']
    $ca_file = "${nsxv_config_dir}/ca.pem"

    file { "${ca_file}":
      ensure  => present,
      content => $ca_certificate_content,
      require => Exec['nsxv_config_dir'],
    }
  }

  package { $neutron_plugin_name:
      ensure => latest,
  }
  exec { 'nsxv_config_dir':
    path => '/usr/bin:/usr/sbin:/bin',
    command => "mkdir -p ${nsxv_config_dir}",
    onlyif => "! test -d ${nsxv_config_dir}",
    provider => shell,
  }
  file { "${nsxv_config_dir}/nsx.ini":
    ensure   => file,
    content => template("${module_name}/nsx.ini.erb"),
    require => Exec['nsxv_config_dir'],
  }
  file { $neutron_plugin_file:
    ensure  => link,
    target  => "${nsxv_config_dir}/nsx.ini",
    replace => true,
    require => Exec['nsxv_config_dir'],
  }
}
