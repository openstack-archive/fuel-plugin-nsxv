class nsxv::hiera_override {
  include ::nsxv::params
  hiera_overrides($::nsxv::params::hiera_override_file)
}
