class nsxv::haproxy_nova_metadata_config (
  $metadta_ha_conf = '/etc/haproxy/conf.d/060-nova-metadata-api.cfg',
) {
  include ::openstack::ha::haproxy_restart

  $public_vip = hiera('public_vip')

  file_line { 'metadat_public_listen':
    path => $metadta_ha_conf,
    after => 'listen nova-metadata-api',
    line => "  bind ${public_vip}:8775",
    notify => Exec['haproxy-restart'],
  }
}
