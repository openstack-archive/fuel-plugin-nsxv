class nsxv::patch_neutron_manifest (
  $manifest_file = '/etc/puppet/modules/osnailyfacter/modular/openstack-network/openstack-network-controller.pp',
  $policy_file = '/etc/puppet/files/policy.json',
) {
  file { $manifest_file:
    ensure  => file,
    source  => "puppet:///modules/${module_name}/openstack-network-controller.pp",
    mode    => 644,
    replace => true,
  }
  file { $policy_file:
    ensure  => file,
    source  => "puppet:///modules/${module_name}/policy.json",
    mode    => 644,
    replace => true,
  }
}
