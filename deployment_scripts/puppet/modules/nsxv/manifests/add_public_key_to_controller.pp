class nsxv::add_public_key_to_controller {
  $script_path = '/usr/local/sbin/reconf_neutron_with_new_compute.sh'
  $script_name = basename($script_path)
  $ssh_key = file("${module_name}/compute_vmware_key.pub")

  file_line { 'add_private_key':
    ensure  => present,
    path    => '/root/.ssh/authorized_keys',
    line    => "command=\"${script_path}\",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ${ssh_key}",
    match   => "^command=\"${script_path}\"",
    replace => true,
  }

  file { $script_path:
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/${script_name}",
    replace => true,
  }
}
