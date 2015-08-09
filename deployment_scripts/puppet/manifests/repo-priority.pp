notice('fuel-plugin-nsxv: repo-priority.pp')

class { '::nsxv::repo_priority':
  plugin_name => "NAME",
  plugin_version => "VERSION",
}
