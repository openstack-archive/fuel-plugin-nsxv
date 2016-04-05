class nsxv::neutron_haproxy_config {
  include openstack::ha::haproxy_restart

  file { '/tmp/neutron-haproxy-config.sh':
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/neutron-haproxy-config.sh",
    replace => true,
  }
  exec { 'neutron active/backup mode':
    command   => '/tmp/neutron-haproxy-config.sh',
    logoutput => on_failure,
    provider  => 'shell',
    require   => File['/tmp/neutron-haproxy-config.sh'],
    notify    => Exec['haproxy-restart']
  }
}
