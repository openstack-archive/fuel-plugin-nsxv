notice('fuel-plugin-nsxv: nova-neutron-timeout-fix.pp')

include ::nsxv::params

nova_config { 'neutron/timeout': value => $::nsxv::params::neutron_url_timeout }
