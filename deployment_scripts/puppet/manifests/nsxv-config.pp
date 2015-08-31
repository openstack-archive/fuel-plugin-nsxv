notice('fuel-plugin-nsxv: nova-config.pp')

include ::nsxv::params

exec { 'nsxv_config_dir':
  path => '/usr/bin:/usr/sbin:/bin',
  command => "mkdir -p ${::nsxv::params::nsxv_config_dir}",
  onlyif => "! test -d ${::nsxv::params::nsxv_config_dir}",
  provider => shell,
}
concat { $::nsxv::params::neutron_plugn_config:
  ensure => present,
  ensure_newline => true,
  order => 'numeric',
  replace => true,
  require => Exec['nsxv_config_dir'],
}
concat::fragment{ 'neutron_plugin_config':
  ensure => present,
  target  => $::nsxv::params::neutron_plugn_config,
  content => "NEUTRON_PLUGIN_CONFIG='${::nsxv::params::nsxv_config_dir}/nsx.ini'",
  order   => '01'
}
file { "${::nsxv::params::nsxv_config_dir}/nsx.ini":
  ensure   => file,
#  content => template("${module_name}/nsx.ini.erb"),
  content => template("nsxv/nsx.ini.erb"),
  require => Exec['nsxv_config_dir'],
}
