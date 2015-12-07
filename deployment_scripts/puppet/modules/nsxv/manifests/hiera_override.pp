class nsxv::hiera_override (
  $plugin_name,
) {
  $override_file = "/etc/hiera/override/${plugin_name}.yaml"
  $override_dir = dirname($override_file)

  $neutron_config = inline_template("<%-
    require 'yaml'
    settings = scope.function_hiera(['neutron_config'])
    settings['predefined_networks'] = {}
    neutron_config = { 'neutron_config' => settings }
  -%>
<%= neutron_config.to_yaml %>")

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

  $neutron_advanced_configuration = inline_template("<%-
    require 'yaml'
    neutron_advanced_configuration = { 'neutron_advanced_configuration' => scope.function_hiera(['neutron_advanced_configuration']) }
    neutron_advanced_configuration['neutron_advanced_configuration']['neutron_dvr'] = false
    neutron_advanced_configuration['neutron_advanced_configuration']['neutron_l2_pop'] = false
  -%>
<%= neutron_advanced_configuration.to_yaml %>")

  $override_testvm_image = inline_template("<%-
    require 'yaml'
    test_vm_image = {}
    test_vm_image['os_name'] = 'TinyCoreLinux'
    test_vm_image['img_path'] = '/usr/share/tcl-testvm/tcl.vmdk'
    test_vm_image['container_format'] = 'bare'
    test_vm_image['min_ram'] = '128'
    test_vm_image['disk_format'] = 'vmdk'
    test_vm_image['glance_properties'] = '--property hypervisor_type=vmware --property vmware_disktype=streamOptimized --property vmware_adaptertype=lsiLogic'
    test_vm_image['img_name'] = 'TestVM-VMDK'
    test_vm_image['public'] = 'true'
    override_testvm_image = { 'test_vm_image' => test_vm_image }
  -%>
<%= override_testvm_image.to_yaml %>")

  file { $override_dir:
    ensure => directory,
  } ->
  concat { $override_file:
    ensure         => present,
    ensure_newline => true,
    order          => 'numeric',
    replace        => true,
  }
  concat::fragment{ 'quantum_settings':
    ensure  => present,
    target  => $override_file,
    content => regsubst($neutron_config,'neutron_config','quantum_settings'),
    order   => '01'
  }
  concat::fragment{ 'neutron_config':
    ensure  => present,
    target  => $override_file,
    content => regsubst($neutron_config,'---',''),
    order   => '05'
  }
  concat::fragment{ 'network_metadata':
    ensure  => present,
    target  => $override_file,
    content => regsubst($network_metadata,'---',''),
    order   => '10'
  }
  concat::fragment{ 'network_scheme':
    ensure  => present,
    target  => $override_file,
    content => regsubst($network_scheme,'---',''),
    order   => '20'
  }
  concat::fragment{ 'neutron_advanced_configuration':
    ensure  => present,
    target  => $override_file,
    content => regsubst($neutron_advanced_configuration,'---',''),
    order   => '30'
  }
  concat::fragment{ 'override-testvm-image':
    ensure  => present,
    target  => $override_file,
    content => regsubst($override_testvm_image,'---',''),
    order   => '40'
  }

  file_line {"${plugin_name}_hiera_override":
    path  => '/etc/hiera.yaml',
    line  => "  - override/${plugin_name}",
    after => '  - override/module/%{calling_module}',
  }
}
