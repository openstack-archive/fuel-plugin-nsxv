notice('fuel-plugin-nsxv: delete-old-hiera-override.pp')

include ::nsxv::params

file { $::nsxv::params::hiera_override_file:
  ensure  => absent,
}
