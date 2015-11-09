class nsxv::neutron_server_policy (
  $policy_dir = '/etc/neutron/policy.d'
) {
  file { $policy_dir:
    ensure  => directory,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/policy.d",
    recurse => true,
  }
}
