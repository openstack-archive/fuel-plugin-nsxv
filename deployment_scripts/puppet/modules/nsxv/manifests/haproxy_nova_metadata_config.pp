class nsxv::haproxy_nova_metadata_config (
  $metadata_listen,
) {
  file { '/tmp/haproxy-nova-metadata-config.sh':
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/haproxy-nova-metadata-config.sh",
    replace => true,
  }
  exec { 'set nova metadata listen ip':
    command   => "/tmp/haproxy-nova-metadata-config.sh ${metadata_listen}",
    logoutput => on_failure,
    provider  => 'shell',
    require   => File['/tmp/haproxy-nova-metadata-config.sh'],
  }
}
