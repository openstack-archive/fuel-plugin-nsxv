notice('fuel-plugin-nsxv: haproxy-nova-metadata-config.pp')

include ::openstack::ha::haproxy_restart
include ::nsxv::params

$settings = hiera($::nsxv::params::plugin_name)

if $settings['nsxv_metadata_listen_mgmt'] {
  $metadata_listen_ip = hiera('management_vip')
} else {
  $metadata_listen_ip = hiera('public_vip')
}

class { 'nsxv::haproxy_nova_metadata_config':
  metadata_listen => "${metadata_listen_ip}:${::nsxv::params::nova_metadata_port}",
  notify          => Exec['haproxy-restart'],
}
