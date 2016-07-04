class nsxv::params {
  $neutron_url_timeout = '900' # seconds
  $plugin_name         = 'nsxv'
  $nova_metadata_port  = '8775'

  $core_plugin       = 'vmware_nsx.plugin.NsxVPlugin'
  $service_plugins   = 'neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2'
  $service_providers = 'LOADBALANCERV2:VMWareEdge:neutron_lbaas.drivers.vmware.edge_driver_v2.EdgeLoadBalancerDriverV2:default'

  $nsxv_config_dirs = [ '/etc/neutron', '/etc/neutron/plugins', '/etc/neutron/plugins/vmware' ]
  $nsxv_config_dir  = '/etc/neutron/plugins/vmware'
}
