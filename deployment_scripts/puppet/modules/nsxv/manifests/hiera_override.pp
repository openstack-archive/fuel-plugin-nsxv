class nsxv::hiera_override (
  $override_file = '/etc/hiera/override/plugins_nsxv.yaml',
) {
  $override_dir = dirname($override_file)

  $quantum_settings = inline_template("<%-
    require 'yaml'
    settings = scope.function_hiera(['quantum_settings'])
    settings['predefined_networks'] = {}
    quantum_settings = { 'quantum_settings' => settings }
  -%>
<%= quantum_settings.to_yaml %>")

  $network_metadata = inline_template("<%-
    require 'yaml'
    delete_roles = ['neutron/floating','neutron/mesh','neutron/private']
    network_metadata = { 'network_metadata' => scope.function_hiera(['network_metadata']) }
    nodes = network_metadata['network_metadata']['nodes']
    nodes.each do |node, meta|
      (nodes[node]['network_roles']).delete_if { | key, value | delete_roles.include?(key) }
    end
  -%>
<%= network_metadata.to_yaml %>")

  $network_scheme = inline_template("<%-
    require 'yaml'
    delete_bridges = ['br-mesh','br-floating']
    network_scheme = { 'network_scheme' => scope.function_hiera(['network_scheme']) }

    transformations = network_scheme['network_scheme']['transformations']
    transformations.delete_if { |action| action['action'] == 'add-br' and delete_bridges.include?(action['name']) }
    transformations.delete_if { |action| action['action'] == 'add-patch' and not (action['bridges'] & delete_bridges).empty? }
    transformations.delete_if { |action| action['action'] == 'add-port' and delete_bridges.include?(action['bridge']) }

    roles = network_scheme['network_scheme']['roles']
    roles.delete_if { |role, bridge| delete_bridges.include?(bridge) }

    endpoints = network_scheme['network_scheme']['endpoints']
    endpoints.delete_if { |bridge, value| delete_bridges.include?(bridge) }
  -%>
<%= network_scheme.to_yaml %>")

  $public_network_assignment = inline_template("<%-
    require 'yaml'
    public_network_assignment = { 'public_network_assignment' => scope.function_hiera(['public_network_assignment']) }
    public_network_assignment['public_network_assignment']['assign_to_all_nodes'] = true
  -%>
<%= public_network_assignment.to_yaml %>")

  $neutron_advanced_configuration = inline_template("<%-
    neutron_advanced_configuration = { 'neutron_advanced_configuration' => scope.function_hiera(['neutron_advanced_configuration']) }
    neutron_advanced_configuration['neutron_advanced_configuration']['neutron_dvr'] = false
    neutron_advanced_configuration['neutron_advanced_configuration']['neutron_l2_pop'] = false
  -%>
<%= neutron_advanced_configuration.to_yaml %>")

  file { $override_dir:
    ensure => directory,
  } ->
  concat { $override_file:
    ensure => present,
    ensure_newline => true,
    order => 'numeric',
    replace => true,
  }
  concat::fragment{ 'quantum_settings':
    ensure => present,
    target  => $override_file,
    content => $quantum_settings,
    order   => '01'
  }
  concat::fragment{ 'network_metadata':
    ensure => present,
    target  => $override_file,
    content => regsubst($network_metadata,'---',''),
    order   => '10'
  }
  concat::fragment{ 'network_scheme':
    ensure => present,
    target  => $override_file,
    content => regsubst($network_scheme,'---',''),
    order   => '20'
  }
  concat::fragment{ 'public_network_assignment':
    ensure => present,
    target  => $override_file,
    content => regsubst($public_network_assignment,'---',''),
    order   => '30'
  }
  concat::fragment{ 'neutron_advanced_configuration':
    ensure => present,
    target  => $override_file,
    content => regsubst($neutron_advanced_configuration,'---',''),
    order   => '40'
  }
}
