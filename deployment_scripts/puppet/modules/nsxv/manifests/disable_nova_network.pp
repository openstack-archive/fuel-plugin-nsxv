class nsxv::disable_nova_network (
  $nova_network_service_name = 'p_vcenter_nova_network',
  $nova_network_config_ha    = '/etc/nova/nova-network.d/nova-network-ha.conf',
) {
  include ::nova::params

  $access_hash     = hiera_hash('access',{})
  $controller_node = hiera('service_endpoint')
  $os_username     = $access_hash['user']
  $os_password     = $access_hash['password']
  $os_auth_url     = "http://${controller_node}:5000/v2.0/"

  cs_resource { "${nova_network_service_name}":
    ensure => absent,
    notify => Exec["workaround_delete_${nova_network_service_name}"]
  }

  exec { "workaround_delete_${nova_network_service_name}":
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => "pcs resource delete ${nova_network_service_name}",
    refreshonly => true,
    tries       => 3,
    try_sleep   => 10,
  }
  package { 'nova-network':
    name    => $::nova::params::network_package_name,
    ensure  => purged,
    require => Cs_resource["${nova_network_service_name}"],
  }
  file { "${nova_network_config_ha}":
    ensure => absent,
  }

  exec { 'delete-nova-network':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => 'nova service-list --binary nova-network|awk \'/nova-network/ {print $2}\'|while read id; do nova service-delete $id; done',
    onlyif      => 'nova service-list --binary nova-network|grep \'nova-network\' 1>/dev/null',
    provider    => shell,
    environment => [
      'OS_TENANT_NAME=services',
      "OS_USERNAME=${os_username}",
      "OS_PASSWORD=${os_password}",
      "OS_AUTH_URL=${os_auth_url}",
      'OS_ENDPOINT_TYPE=internalURL'
    ],
    tries       => 3,
    try_sleep   => 10,
    require     => Cs_resource["${nova_network_service_name}"],
  }
}
