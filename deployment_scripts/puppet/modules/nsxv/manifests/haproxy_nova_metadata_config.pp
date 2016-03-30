class nsxv::haproxy_nova_metadata_config (
  $metadata_listen_ip,
) {
  file { '/tmp/nova-haproxy-config.sh':
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/nova-haproxy-config.sh",
    replace => true,
  }
  exec { 'set nova metadata listen ip':
    command   => "/tmp/nova-haproxy-config.sh ${metadata_listen_ip}",
    logoutput => on_failure,
    provider  => 'shell',
    require   => File['/tmp/nova-haproxy-config.sh'],
  }
}
