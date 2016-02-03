notice('fuel-plugin-nsxv: horizon-enable-lbaas.pp')

$horizon_settings_file ='/etc/openstack-dashboard/local_settings.py'
$apache_service        ='apache2'

exec { 'enable_lbaas':
  command  => "sed -ri \"s/^(\\s*)'enable_lb':.*/\\1'enable_lb': True,/g\" ${horizon_settings_file}",
  unless   => "egrep \"^\\s*'enable_lb':\\s*True\" ${horizon_settings_file}",
  path     => '/bin:/usr/bin',
  provider => 'shell',
}
service{ $apache_service:
  ensure => 'running',
}
Exec['enable_lbaas'] ~> Service[$apache_service]
