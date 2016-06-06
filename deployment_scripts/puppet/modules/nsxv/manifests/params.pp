class nsxv::params {

  # plugins hiera section/key
  $plugin_name = 'nsxv'

  $nsx_plugin_pkg   = 'python-vmware-nsx'
  $lbaas_plugin_pkg = 'python-neutron-lbaas'
  $test_image_pkg   = 'tcl-testvm'

  $plugin_config_dir = '/etc/neutron/plugins/vmware'
  $config_dirs       = [ '/etc/neutron', '/etc/neutron/plugins', '/etc/neutron/plugins/vmware' ]

  # neutron.conf related settings
  $core_plugin       = 'vmware_nsx.plugin.NsxVPlugin'
  $service_plugins   = 'neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2'
  $service_providers = 'LOADBALANCERV2:VMWareEdge:neutron_lbaas.drivers.vmware.edge_driver_v2.EdgeLoadBalancerDriverV2:default'

  $neutron_url_timeout = '600' # seconds
  $nova_metadata_port  = '8775'
}
