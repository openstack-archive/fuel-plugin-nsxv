notice('fuel-plugin-nsxv: repo-priority.pp')

# Values are changed by pre_build_hook
class { '::nsxv::repo_priority':
  plugin_name    => "NAME",
  plugin_version => "VERSION",
}
