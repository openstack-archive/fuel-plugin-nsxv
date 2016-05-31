class nsxv::neutron_server_check_md_proxy (
  $nsxv_ip,
  $nsxv_user,
  $nsxv_password,
  $datacenter_id,
) {
  file { '/tmp/check_md_proxy.rb':
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/check_md_proxy.rb",
    replace => true,
  }
  exec { 'check_md_proxy':
    tries     => '30',
    try_sleep => '30',
    command   => "ruby /tmp/check_md_proxy.rb '${nsxv_ip}' '${nsxv_user}' '${nsxv_password}' '${datacenter_id}'",
    provider  => 'shell',
    logoutput => on_failure,
    require   => File['/tmp/check_md_proxy.rb'],
  }
}
