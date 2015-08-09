notice('fuel-plugin-nsxv: hiera-override.pp')

class { '::nsxv::hiera_override':
  plugin_name => "NAME",
}
