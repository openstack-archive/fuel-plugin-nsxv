notice('fuel-plugin-nsxv: nova-neutron-timeout-fix.pp')

$neutron_url_timeout = '600'
# NOT enabled by default
$use_neutron         = hiera('use_neutron', false)

if ($use_neutron) {
  nova_config { 'neutron/url_timeout': value => $neutron_url_timeout }
}
