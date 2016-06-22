notice('fuel-plugin-nsxv: neutron-server-stop.pp')

include ::neutron::params

service { 'neutron-server-stop':
  ensure     => 'stopped',
  name       => $::neutron::params::server_service,
}
