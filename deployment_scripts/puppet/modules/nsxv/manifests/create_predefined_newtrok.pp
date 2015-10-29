class nsxv::create_predefined_newtrok (
  $os_tenant_name = 'admin',
  $os_username,
  $os_password,
  $os_auth_url,
  $net_name = 'net04',
  $ext_net_name = 'net04_ext',
) {

  $settings = hiera('nsxv')

  if !empty($settings['nsxv_floating_ip_range']) and !empty($settings['nsxv_floating_ip_cidr']) {
    $net04_ext_floating_range = split($settings['nsxv_floating_ip_range'], ',')
    $net04_ext_floating_range_start = $net04_ext_floating_range[0]
    $net04_ext_floating_range_end   = $net04_ext_floating_range[1]
    $net04_ext_allocation_pool = "start=${net04_ext_floating_range_start},end=${net04_ext_floating_range_end}"

    neutron_network { $ext_net_name :
      ensure                    => 'present',
      provider_physical_network => $settings['nsxv_external_network'],
      provider_network_type     => 'flat',
      router_external           => true,
      tenant_name               => $os_tenant_name,
      shared                    => true,
    }
    neutron_subnet { "${ext_net_name}_subnet" :
      ensure           => 'present',
      cidr             => $settings['nsxv_floating_ip_cidr'],
      network_name     => $ext_net_name,
      tenant_name      => $os_tenant_name,
      gateway_ip       => '',
      enable_dhcp      => false,
      allocation_pools => $net04_ext_allocation_pool,
      require          => Neutron_network[$ext_net_name],
    }
  }

  if !empty($settings['nsxv_internal_ip_cidr']) {
    $net04_dns = split($settings['nsxv_internal_ip_dns'], ',')
    $inetrnal_ip_cidr = $settings['nsxv_internal_ip_cidr']

    # I cannot skip provider_network_type, if use 'vxlan' need define provider_segmentation_id, but get error 'Segmentation ID cannot be set with VXLAN'
    #neutron_network { $net_name :
    #  ensure                    => 'present',
    #  provider_physical_network => false,
    #  provider_network_type     => 'vxlan',
    #  provider_segmentation_id  => '5010',
    #  router_external           => false,
    #  tenant_name               => $os_tenant_name,
    #  shared                    => false,
    #} ->
    exec { "create_${net_name}":
      path        => '/sbin:/usr/sbin:/bin:/usr/bin',
      environment => [
        "OS_TENANT_NAME=${os_tenant_name}",
        "OS_USERNAME=${os_username}",
        "OS_PASSWORD=${os_password}",
        "OS_AUTH_URL=${os_auth_url}",
        'OS_ENDPOINT_TYPE=internalURL',
      ],
      command     => "neutron --insecure net-create ${net_name}",
      unless      => "neutron --insecure net-list && (neutron --insecure net-list | grep '${net_name} ')",
    }->
    neutron_subnet { "${net_name}_subnet" :
      ensure          => 'present',
      cidr            => $inetrnal_ip_cidr,
      network_name    => $net_name,
      tenant_name     => $os_tenant_name,
      gateway_ip      => regsubst($inetrnal_ip_cidr,'^(\d+\.\d+\.\d+)\.\d+/\d+$','\1.1'),
      enable_dhcp     => true,
      dns_nameservers => pick($net04_dns,[]),
      require         => Exec["create_${net_name}"],
    }
  }
}
