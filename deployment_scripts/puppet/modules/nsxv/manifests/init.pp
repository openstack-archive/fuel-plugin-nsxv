class nsxv (
  $nsxv_config_dir = $::nsxv::params::nsxv_config_dir,
  $neutron_plugin_config = '/etc/default/neutron-server',
  $neutron_plugin_name = 'python-vmware-nsx',
) inherits ::nsxv::params {

  $quantum_settings = hiera('quantum_settings')

  $settings = hiera('nsxv')
  $nova_metadata_ips = hiera('public_vip') 
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
  concat { $neutron_plugin_config:
    ensure => present,
    ensure_newline => true,
    order => 'numeric',
    replace => true,
    require => Exec['nsxv_config_dir'],
  }
  concat::fragment{ 'neutron_plugin_config':
    ensure => present,
    target  => $neutron_plugin_config,
    content => "NEUTRON_PLUGIN_CONFIG='${nsxv_config_dir}/nsx.ini'",
    order   => '01'
  }
  file { "${nsxv_config_dir}/nsx.ini":
    ensure   => file,
    content => template("${module_name}/nsx.ini.erb"),
    require => Exec['nsxv_config_dir'],
  }
}
