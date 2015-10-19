notice('fuel-plugin-nsxv: upload-glance-image.pp')

$access_hash     = hiera_hash('access',{})
$controller_node = hiera('service_endpoint')

class { '::nsxv::upload_image':
  os_username => $access_hash['user'],
  os_password => $access_hash['password'],
  os_auth_url => "http://${controller_node}:5000/v2.0/",
}
