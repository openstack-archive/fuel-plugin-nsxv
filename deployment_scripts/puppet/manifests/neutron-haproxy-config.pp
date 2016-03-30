notice('fuel-plugin-nsxv: neutron-haproxy-config.pp')

include openstack::ha::haproxy_restart

class { '::nsxv::neutron_haproxy_config':
  notify => Exec['haproxy-restart'],
}
