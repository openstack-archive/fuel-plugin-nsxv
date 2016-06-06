notice('fuel-plugin-nsxv: neutron-configure-common.pp')

include ::nsxv::params

neutron_config {
  'DEFAULT/core_plugin':                value => $::nsxv::params::core_plugin;
  'DEFAULT/service_plugins':            value => $::nsxv::params::service_plugins;
  'service_providers/service_provider': value => $::nsxv::params::service_providers;
}
