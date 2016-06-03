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

    # override neutron_advanced_configuration
    neutron_advanced_configuration = {}
    neutron_advanced_configuration['neutron_dvr'] = false
    neutron_advanced_configuration['neutron_l2_pop'] = false
    neutron_advanced_configuration['neutron_l3_ha'] = false
    neutron_advanced_configuration['neutron_qos'] = false
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

    # override storage settings
    storage = function_hiera_hash(['storage'])
    storage['volumes_block_device'] = false
    storage['volumes_ceph'] = false
    storage['volumes_lvm'] = false
    storage['ephemeral_ceph'] = false
    storage['volume_backend_names'] = { 'volumes_block_device' => false,
                                        'volumes_ceph' => false,
                                        'volumes_lvm' => false }
    hiera_overrides['storage'] = storage

    # write to hiera override yaml file
    File.open(filename, 'w') { |file| file.write(hiera_overrides.to_yaml) }
  end
end
