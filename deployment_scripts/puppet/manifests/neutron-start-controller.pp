notice('fuel-plugin-nsxv: neutron-start-controller.pp')

include ::neutron::params

exec { 'neutron-server-stop':
  path     => '/usr/sbin:/usr/bin:/sbin:/bin',
  command  => "service ${::neutron::params::server_service} stop",
  provider => 'shell',
  onlyif   => "service ${::neutron::params::server_service} status|grep -q running",
}

service { 'neutron-server-start':
  ensure     => 'running',
  name       => $::neutron::params::server_service,
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
}

Exec['neutron-server-stop']~>Service['neutron-server-start']
