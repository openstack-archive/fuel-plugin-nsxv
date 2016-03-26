class nsxv::hiera_override (
  $plugin_name,
) {
  $override_file = "/etc/hiera/override/${plugin_name}.yaml"
  $override_dir = dirname($override_file)

  $quantum_settings = inline_template("<%-
    require 'yaml'
    settings = scope.function_hiera(['quantum_settings'])
    settings['predefined_networks'] = {}
    quantum_settings = { 'quantum_settings' => settings }
  -%>
<%= quantum_settings.to_yaml %>")

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
    ensure         => present,
    ensure_newline => true,
    order          => 'numeric',
    replace        => true,
  }
  concat::fragment{ 'quantum_settings':
    ensure  => present,
    target  => $override_file,
    content => $quantum_settings,
    order   => '01'
  }
  concat::fragment{ 'neutron_advanced_configuration':
    ensure  => present,
    target  => $override_file,
    content => regsubst($neutron_advanced_configuration,'---',''),
    order   => '30'
  }

  file_line {"${plugin_name}_hiera_override":
    path  => '/etc/hiera.yaml',
    line  => "  - override/${plugin_name}",
    after => '  - override/module/%{calling_module}',
  }
  file_line {"${plugin_name}_hiera_override_pre_deployment":
    path  => '/etc/hiera.yaml',
    line  => "  - override/${plugin_name}_pre_deployment",
    after => "  - override/${plugin_name}",
    require => File_line["${plugin_name}_hiera_override"],
  }
}
