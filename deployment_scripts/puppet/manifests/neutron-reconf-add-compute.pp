notice('fuel-plugin-nsxv: neutron-reconf-add-compute.pp')

$use_neutron = hiera('use_neutron', false)

if ($use_neutron) {
  $controllers = get_controllers_ip(hiera('nodes'))
  exec { 'random_wait':
    command  => "/bin/bash -c 'sleep  $((RANDOM%30))'",
    provider => 'posix',
  }
  ssh_to_controller { $controllers:
    require => Exec['random_wait'],
  }
}

# workaround for use $name, else not work
define ssh_to_controller() {
  exec { $name:
    command   => "ssh -l root -i /root/.ssh/compute_vmware_key -T -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' ${name}",
    path      => '/usr/bin:/usr/sbin:/bin',
    provider  => shell,
    tries     => 3,
    try_sleep => 10,
    logoutput => on_failure,
  }
}
