class nsxv::haproxy_neutron_config {
  file { '/tmp/haproxy-neutron-config.sh':
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/haproxy-neutron-config.sh",
    replace => true,
  }
  exec { 'neutron active/backup mode':
    command     => '/tmp/haproxy-neutron-config.sh',
    logoutput   => on_failure,
    provider    => 'shell',
    require     => File['/tmp/haproxy-neutron-config.sh'],
  }
}
