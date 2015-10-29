notice('fuel-plugin-nsxv: create-predefined-newtrok.pp')

$access_hash     = hiera_hash('access',{})
$controller_node = hiera('service_endpoint')

class { '::nsxv::create_predefined_newtrok':
  os_username => $access_hash['user'],
  os_password => $access_hash['password'],
  os_auth_url => "http://${controller_node}:5000/v2.0/",
}
