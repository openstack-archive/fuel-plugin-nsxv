class nsxv::hiera_override (
  $override_file = '/etc/hiera/override/plugins_nsxv.yaml',
  $neutron_bridge = 'br-mgmt',
) {
  $override_dir = dirname($override_file)

  $network_roles_on_neutron_bridge = inline_template("<%-
    network_scheme = scope.function_hiera(['network_scheme'])
    roles = network_scheme['roles']
  -%>
<%= roles.key(scope.lookupvar('neutron_bridge')) %>")

  $network_scheme_patch = inline_template("<%-
    require 'yaml'
    network_scheme = {}
    network_scheme['network_scheme'] = scope.function_hiera(['network_scheme'])
    network_scheme['network_scheme']['roles']['neutron/api'] = scope.lookupvar('neutron_bridge')
  -%>
<%= network_scheme.to_yaml %>")

  $neutron_nodes = inline_template("<%-
    require 'yaml'
    neutron_nodes = {}
    nodes = scope.function_hiera_hash(['neutron_nodes'])
    neutron_nodes['neutron_nodes'] = nodes
    nodes.each do |node, meta|
      neutron_nodes['neutron_nodes'][node]['network_roles']['neutron/api'] = neutron_nodes['neutron_nodes'][node]['network_roles'][(scope.lookupvar('network_roles_on_neutron_bridge')).strip]
    end
  -%>
<%= neutron_nodes.to_yaml %>")

  file { $override_dir:
    ensure => directory,
  } ->
  concat { $override_file:
    ensure => present,
    ensure_newline => true,
    order => 'numeric',
    replace => true,
  }
  concat::fragment{ 'network_scheme':
    ensure => present,
    target  => $override_file,
    content => $network_scheme_patch,
    order   => '01'
  }
  concat::fragment{ 'neutron_nodes':
    ensure => present,
    target  => $override_file,
    content => regsubst($neutron_nodes,'---',''),
    order   => '10'
  }
  concat::fragment{ 'use_neutron':
    ensure => present,
    target  => $override_file,
    content => "  use_neutron: true",
    order   => '20'
  }
}
