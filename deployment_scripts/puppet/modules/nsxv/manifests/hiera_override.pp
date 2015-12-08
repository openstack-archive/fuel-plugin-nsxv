class nsxv::hiera_override (
  $plugin_name,
) {
  $override_file = "/etc/hiera/override/${plugin_name}.yaml"
  $override_dir = dirname($override_file)

  exec { "${plugin_name}_hiera_override":
    command  => "sed -ri 's|^((\\s+-\\s+)\"override/module/%\\{calling_module\\}\")|\\1\\n\\2override/${plugin_name}|' /etc/hiera.yaml",
    unless   => "grep -q \"override/${plugin_name}\" /etc/hiera.yaml",
    path     => '/bin:/usr/bin',
    provider => 'shell',
  }
  file { $override_dir:
    ensure => directory,
  }
  hiera_overrides($override_file)
}
