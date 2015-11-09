notice('fuel-plugin-nsxv: neutron-network-create.pp')

# NOT enabled by default
$use_neutron         = hiera('use_neutron', false)

if ($use_neutron) {
  $access_hash     = hiera_hash('access',{})
  $controller_node = hiera('service_endpoint')
  $neutron_config  = hiera_hash('neutron_config')
  $floating_net    = try_get_value($neutron_config, 'default_floating_net', 'net04_ext')
  $internal_net    = try_get_value($neutron_config, 'default_private_net', 'net04')
  $os_tenant_name  = $access_hash['tenant']
  $os_username     = $access_hash['user']
  $os_password     = $access_hash['password']
  $os_auth_url     = "http://${controller_node}:5000/v2.0/"
  $settings        = hiera('nsxv')

  if !empty($settings['nsxv_floating_ip_range']) and !empty($settings['nsxv_floating_net_cidr']) {
    $floating_ip_range = split($settings['nsxv_floating_ip_range'], '-')
    $floating_ip_range_start = $floating_ip_range[0]
    $floating_ip_range_end   = $floating_ip_range[1]
    $floating_net_allocation_pool = "start=${floating_ip_range_start},end=${floating_ip_range_end}"

    $floating_net_cidr = $settings['nsxv_floating_net_cidr']
    $floating_net_gw = $settings['nsxv_floating_net_gw']
    $default_floating_net_gw = regsubst($floating_net_cidr,'^(\d+\.\d+\.\d+)\.\d+/\d+$','\1.1')

    neutron_network { $floating_net :
      ensure                    => 'present',
      provider_physical_network => $settings['nsxv_external_network'],
      provider_network_type     => 'flat',
      router_external           => true,
      tenant_name               => $os_tenant_name,
      shared                    => true,
    }
    neutron_subnet { "${floating_net}__subnet" :
      ensure           => 'present',
      cidr             => $floating_net_cidr,
      network_name     => $floating_net,
      tenant_name      => $os_tenant_name,
      gateway_ip       => pick($floating_net_gw,$default_floating_net_gw),
      enable_dhcp      => false,
      allocation_pools => $floating_net_allocation_pool,
      require          => Neutron_network[$floating_net],
    }
  }

  if !empty($settings['nsxv_internal_net_cidr']) {
    $internal_net_dns = split($settings['nsxv_internal_net_dns'], ',')
    $internal_net_cidr = $settings['nsxv_internal_net_cidr']

    exec { "create_${internal_net}":
      path        => '/sbin:/usr/sbin:/bin:/usr/bin',
      environment => [
        "OS_TENANT_NAME=${os_tenant_name}",
        "OS_USERNAME=${os_username}",
        "OS_PASSWORD=${os_password}",
        "OS_AUTH_URL=${os_auth_url}",
        'OS_ENDPOINT_TYPE=internalURL',
      ],
      command     => "neutron --insecure net-create ${internal_net}",
      unless      => "neutron --insecure net-list && (neutron --insecure net-list | grep '${internal_net} ')",
    }
    neutron_subnet { "${internal_net}__subnet" :
      ensure          => 'present',
      cidr            => $internal_net_cidr,
      network_name    => $internal_net,
      tenant_name     => $os_tenant_name,
      gateway_ip      => regsubst($internal_net_cidr,'^(\d+\.\d+\.\d+)\.\d+/\d+$','\1.1'),
      enable_dhcp     => true,
      dns_nameservers => pick($internal_net_dns,[]),
      require         => Exec["create_${internal_net}"],
    }
  }
}
