notice('fuel-plugin-nsxv: haproxy-neutron-config.pp')

include openstack::ha::haproxy_restart

class { '::nsxv::haproxy_neutron_config':
  notify => Exec['haproxy-restart'],
}
