notice('fuel-plugin-nsxv: hiera-override.pp')

# Values are changed by pre_build_hook
class { '::nsxv::hiera_override':
  plugin_name => "NAME",
}
