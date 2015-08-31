notice('fuel-plugin-nsxv: disable-nova-network.pp')

include ::nsxv::params
include ::nova::params

cs_resource { "${::nsxv::params::nova_network_service_name}":
  ensure => absent,
}
package { 'nova-network':
  name   => $::nova::params::network_package_name,
  ensure => absent,
  require => Cs_resource["${::nsxv::params::nova_network_service_name}"],
}
file { "${::nsxv::params::nova_network_config_ha}":
  ensure => absent,
}
exec { 'delete-nova-network':
  path => '/usr/bin:/usr/sbin:/bin',
  command => 'source /root/openrc ; nova service-list --binary nova-network|awk \'/nova-network/ {print $2}\'|while read id; do nova service-delete $id; done',
  onlyif => 'source /root/openrc ; nova service-list --binary nova-network|grep \'nova-network\' 1>/dev/null',
  provider => shell,
}
