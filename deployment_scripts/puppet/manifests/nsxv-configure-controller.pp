notice('fuel-plugin-nsxv: nsxv-configure-controller.pp')

include nsxv::params

nsx_config { "${::nsxv::params::plugin_name}/metadata_initializer": value => "false" }
