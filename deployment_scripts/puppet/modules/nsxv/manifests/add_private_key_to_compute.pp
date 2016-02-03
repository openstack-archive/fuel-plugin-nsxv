class nsxv::add_private_key_to_compute {
  file { '/root/.ssh/compute_vmware_key':
    ensure  => file,
    mode    => '0600',
    source  => "puppet:///modules/${module_name}/compute_vmware_key",
    replace => true,
  }
}
