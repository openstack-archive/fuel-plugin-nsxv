class nsxv::patch_neutron_manifest (
  $manifest_file = '/etc/puppet/modules/osnailyfacter/modular/openstack-network/openstack-network-controller.pp',
  $policy_dir = '/etc/neutron/policy.d'
) {
  $neutron_dir = '/etc/neutron'

  file { $manifest_file:
    ensure  => file,
    source  => "puppet:///modules/${module_name}/openstack-network-controller.pp",
    mode    => '0644',
    replace => true,
  }
  file { $neutron_dir:
    ensure  => directory,
    mode    => '0755',
  }
  file { $policy_dir:
    ensure  => directory,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/policy.d",
    recurse => true,
    require => File[$neutron_dir], 
  }
}
