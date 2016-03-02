class nsxv (
  $nsxv_config_dir = '/etc/neutron/plugins/vmware',
  $neutron_plugin_name = 'python-vmware-nsx',
  $lbaas_plugin_name = 'python-neutron-lbaas',
  $plugin_name = 'nsxv',
  $neutron_url_timeout = '600',
) {

  $neutron_config = hiera_hash('neutron_config')
  $settings = hiera($plugin_name)

  # Do not remove unused variables: template nsx.ini.erb refers to them
  $nova_metadata_ips = hiera('public_vip')
  $nova_metadata_port = '8775'
  $metadata_shared_secret = $neutron_config['metadata']['metadata_proxy_shared_secret']
  $nsxv_config_dirs = [ '/etc/neutron', '/etc/neutron/plugins', '/etc/neutron/plugins/vmware' ]
  $cluster_moid = get_vcenter_cluster_id($settings['nsxv_datacenter_moid'])

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
