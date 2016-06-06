Puppet::Type.type(:nsx_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def file_path
    '/etc/neutron/plugins/vmware/nsx.ini'
  end

end
