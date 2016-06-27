notice('fuel-plugin-nsxv: nova-api-restart.pp')

include ::nova::params

exec {'nova-api-restart':
  path     => '/usr/sbin:/usr/bin:/sbin:/bin',
  command  => "service ${::nova::params::api_service_name} restart",
  provider => 'shell',
  onlyif   => "service ${::nova::params::api_service_name} status|grep -q running",
}
