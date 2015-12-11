class nsxv::hiera_override (
  $plugin_name,
) {
  $override_file = "/etc/hiera/override/${plugin_name}.yaml"
  $override_dir = dirname($override_file)

  file_line {"${plugin_name}_hiera_override":
    path  => '/etc/hiera.yaml',
    line  => "  - override/${plugin_name}",
    after => '  - override/module/%{calling_module}',
  }
  file { $override_dir:
    ensure => directory,
  }
  hiera_overrides($override_file)
}
