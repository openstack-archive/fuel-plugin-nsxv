class nsxv::upload_image (
  $os_tenant_name = 'admin',
  $os_username,
  $os_password,
  $os_auth_url,
  $disk_format = 'vmdk',
  $container_format = 'bare',
  $public = 'true',
  $img_name = 'TestVM-VMDK',
  $img_path = '/usr/share/tcl-testvm/tcl.vmdk',
  $min_ram = 128,
) {
  package { 'tcl-testvm':
    ensure => latest,
  }
  exec { 'remove-img':
    path        => '/sbin:/usr/sbin:/bin:/usr/bin',
    environment => [
      "OS_TENANT_NAME=${os_tenant_name}",
      "OS_USERNAME=${os_username}",
      "OS_PASSWORD=${os_password}",
      "OS_AUTH_URL=${os_auth_url}",
      'OS_ENDPOINT_TYPE=internalURL',
    ],
    command     => "glance -k image-delete ${img_name}",
    unless      => "glance -k image-list && (test -z \"$(glance -k image-list | grep ${img_name})\")",
  }
  exec { 'upload-img':
    path        => '/sbin:/usr/sbin:/bin:/usr/bin',
    environment => [
      "OS_TENANT_NAME=${os_tenant_name}",
      "OS_USERNAME=${os_username}",
      "OS_PASSWORD=${os_password}",
      "OS_AUTH_URL=${os_auth_url}",
      'OS_ENDPOINT_TYPE=internalURL',
    ],
    command     => "glance -k image-create --name=${img_name} --is-public=${public} --container-format=${container_format} --disk-format=${disk_format} --property hypervisor_type='vmware' --property vmware_disktype='streamOptimized' --property vmware_adaptertype='lsilogic' --min-ram ${min_ram} < ${img_path}",
    unless      => "glance -k image-list && (glance -k image-list | grep ${img_name})",
    require     => [Package['tcl-testvm'],Exec['remove-img']],
  }
}
