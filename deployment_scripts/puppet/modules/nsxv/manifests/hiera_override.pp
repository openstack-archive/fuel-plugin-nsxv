class nsxv::hiera_override (
  $plugin_name,
) {
  $override_file = "/etc/hiera/plugins/${plugin_name}.yaml"
  hiera_overrides($override_file)
}
