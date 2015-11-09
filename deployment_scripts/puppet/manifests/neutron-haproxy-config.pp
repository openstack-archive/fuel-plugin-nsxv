notice('fuel-plugin-nsxv: openstack-haproxy-neutron-nsxv.pp')

# NOT enabled by default
$use_neutron         = hiera('use_neutron', false)

$neutron_address_map = get_node_to_ipaddr_map_by_network_role(hiera_hash('neutron_nodes'), 'neutron/api')
if ($use_neutron) {
  $server_names        = hiera_array('neutron_names', keys($neutron_address_map))
  $ipaddresses         = hiera_array('neutron_ipaddresses', values($neutron_address_map))
  $public_virtual_ip   = hiera('public_vip')
  $internal_virtual_ip = hiera('management_vip')
  $public_ssl_hash     = hiera('public_ssl')

  # configure neutron ha proxy
  openstack::ha::haproxy_service { 'neutron':
    internal_virtual_ip    => $internal_virtual_ip,
    ipaddresses            => $ipaddresses,
    public_virtual_ip      => $public_virtual_ip,
    server_names           => $server_names,
    order                  => '085',
    listen_port            => 9696,
    public                 => true,
    public_ssl             => $public_ssl_hash['services'],
    define_backups         => true,
    haproxy_config_options => {
      option               => ['httpchk', 'httplog','httpclose'],
      timeout              => ['client 600s','client-fin 30s','server 600s','server-fin 30s'],
    },
    balancermember_options => 'check inter 10s fastinter 2s downinter 3s rise 3 fall 3',
  }
}
