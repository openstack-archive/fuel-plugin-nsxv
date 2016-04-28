notice('fuel-plugin-nsxv: haproxy-nova-metadata-config.pp')

include ::openstack::ha::haproxy_restart
include ::nsxv::params

$settings = hiera($::nsxv::params::plugin_name)

if $settings['nsxv_metadata_initializer'] {
  $metadata_listen_ip = get_nova_metadata_ip($settings['nsxv_metadata_listen'])

  class { 'nsxv::haproxy_nova_metadata_config':
    metadata_listen => "${metadata_listen_ip}:${::nsxv::params::nova_metadata_port}",
    notify          => Exec['haproxy-restart'],
  }
}
