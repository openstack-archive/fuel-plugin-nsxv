notice('fuel-plugin-nsxv: nova-neutron-timeout-fix.pp')

include ::nova::params

$neutron_url_timeout = '600'
nova_config { 'neutron/timeout': value => $neutron_url_timeout }
