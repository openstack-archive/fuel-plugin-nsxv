require 'yaml'

module Puppet::Parser::Functions
  newfunction(:hiera_overrides, :doc => <<-EOS
Custom function to override hiera parameters, the first argument -
file name, where write new parameters in yaml format, ex:
   hiera_overrides('/etc/hiera/test.yaml')
EOS
  ) do |args|
    filename = args[0]
    hiera_overrides = {}

    # override network_metadata
    delete_roles = ['neutron/floating','neutron/mesh','neutron/private']
    network_metadata = function_hiera_hash(['network_metadata'])
    nodes = network_metadata['nodes']
    nodes.each do |node, meta|
      (nodes[node]['network_roles']).delete_if { | key, value | delete_roles.include?(key) }
    end
    hiera_overrides['network_metadata'] = network_metadata

    # override network_scheme
    delete_bridges = ['br-mesh','br-floating']
    network_scheme = function_hiera_hash(['network_scheme'])

    transformations = network_scheme['transformations']
    transformations.delete_if { |action| action['action'] == 'add-br' and delete_bridges.include?(action['name']) }
    transformations.delete_if { |action| action['action'] == 'add-patch' and not (action['bridges'] & delete_bridges).empty? }
    transformations.delete_if { |action| action['action'] == 'add-port' and delete_bridges.include?(action['bridge']) }

    roles = network_scheme['roles']
    roles.delete_if { |role, bridge| delete_bridges.include?(bridge) }

    endpoints = network_scheme['endpoints']
    endpoints.delete_if { |bridge, value| delete_bridges.include?(bridge) }
    hiera_overrides['network_scheme'] = network_scheme

    # override neutron_advanced_configuration
    neutron_advanced_configuration = function_hiera(['neutron_advanced_configuration'])
    neutron_advanced_configuration['neutron_dvr'] = false
    neutron_advanced_configuration['neutron_l2_pop'] = false
    neutron_advanced_configuration['neutron_l3_ha'] = false
    hiera_overrides['neutron_advanced_configuration'] = neutron_advanced_configuration

    # override testvm image
    test_vm_image = {}
    test_vm_image['os_name'] = 'TinyCoreLinux'
    test_vm_image['img_path'] = '/usr/share/tcl-testvm/tcl.vmdk'
    test_vm_image['container_format'] = 'bare'
    test_vm_image['min_ram'] = '128'
    test_vm_image['disk_format'] = 'vmdk'
    test_vm_image['glance_properties'] = '--property hypervisor_type=vmware --property vmware_disktype=streamOptimized --property vmware_adaptertype=lsiLogic'
    test_vm_image['img_name'] = 'TestVM-VMDK'
    test_vm_image['public'] = 'true'
    hiera_overrides['test_vm_image'] = test_vm_image

    # write to hiera override yaml file
    File.open(filename, 'w') { |file| file.write(hiera_overrides.to_yaml) }
  end
end
