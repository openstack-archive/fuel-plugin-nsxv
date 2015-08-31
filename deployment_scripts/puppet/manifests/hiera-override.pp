notice('fuel-plugin-nsxv: hiera-override-network-scheme.pp')

$override_dir = '/etc/hiera/override'
$override_file = "${override_dir}/plugins.yaml"

prepare_network_config(hiera('network_scheme'))

$neutron_local_address_for_bind = get_network_role_property('neutron/api', 'ipaddr')

$network_scheme = inline_template("<%-
  require 'yaml'
  network_scheme = {}
  network_scheme['network_scheme'] = scope.function_hiera(['network_scheme'])
  network_scheme['network_scheme']['roles']['neutron/api'] = 'br-mgmt'
-%>
<%= network_scheme.to_yaml %>")

$neutron_nodes = inline_template("<%-
  require 'yaml'
  neutron_nodes = {}
  nodes = scope.function_hiera_hash(['neutron_nodes'])
  neutron_nodes['neutron_nodes'] = nodes
  nodes.each do |node, meta|
    neutron_nodes['neutron_nodes'][node]['network_roles']['neutron/api'] = scope.lookupvar('neutron_local_address_for_bind') 
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
  content => $network_scheme,
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
