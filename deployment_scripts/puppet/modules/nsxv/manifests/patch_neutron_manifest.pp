class nsxv::patch_neutron_manifest (
  $manifest_file = '/etc/puppet/modules/osnailyfacter/modular/openstack-network/openstack-network-controller.pp',
  $policy_file = '/etc/puppet/files/policy.json',
  $plugin_name,
) {
  $override_file = "/etc/hiera/override/${plugin_name}_pre_deployment.yaml"
  $override_dir = dirname($override_file)

  $fuel_version = inline_template("<%-
    flag_file = '/etc/puppet/modules/osnailyfacter/modular/openstack-network/openstack-network-controller.pp'
    fuel_version = '7.0MU1'
    File.open(flag_file, 'r') do |file|
      file.each_line do |line|
        if line.include? 'auth_url'
          if line =~ /^\s*auth_url\s*=>\s*\"http:\\/\\/\\$\\{service_endpoint\\}:35357\\/v2.0\"/
            fuel_version = '7.0'
            break
          end
        end
      end
    end
  -%>
<%= fuel_version %>")

  file { $override_dir:
    ensure => directory,
  } ->
  concat { $override_file:
    ensure         => present,
    ensure_newline => true,
    order          => 'numeric',
    replace        => true,
  }
  concat::fragment{ 'set_fuel_version':
    ensure  => present,
    target  => $override_file,
    content => "nsxv_fuel_version: ${fuel_version}",
    order   => '01'
  }

  file { $manifest_file:
    ensure  => file,
    source  => "puppet:///modules/${module_name}/openstack-network-controller.pp",
    mode    => '0644',
    replace => true,
    require => [Concat[$override_file],Concat::Fragment['set_fuel_version']]
  }
  file { $policy_file:
    ensure  => file,
    source  => "puppet:///modules/${module_name}/policy.json",
    mode    => '0644',
    replace => true,
  }
}
