class nsxv::haproxy_nova_metadata_config (
  $metadata_listen,
  $metadata_insecure,
  $metadata_crt_key_file,
) {
  file { '/tmp/haproxy-nova-metadata-config.sh':
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/haproxy-nova-metadata-config.sh",
    replace => true,
  }
  exec { 'set nova metadata listen ip':
    command   => "/tmp/haproxy-nova-metadata-config.sh ${metadata_listen} ${metadata_insecure} ${metadata_crt_key_file}",
    logoutput => on_failure,
    provider  => 'shell',
    require   => File['/tmp/haproxy-nova-metadata-config.sh'],
  }
  
  if ! $metadata_insecure {
    file { '/tmp/generate_haproxy_key.sh':
      ensure  => file,
      mode    => '0755',
      source  => "puppet:///modules/${module_name}/generate_haproxy_key.sh",
      replace => true,
    }
    exec { 'generate key/cert for nova metadata':
      command   => "/tmp/generate_haproxy_key.sh ${metadata_crt_key_file}",
      logoutput => on_failure,
      provider  => 'shell',
      require   => File['/tmp/generate_haproxy_key.sh'],
    }
  }
}
