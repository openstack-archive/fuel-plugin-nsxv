notice('fuel-plugin-nsxv: repo-priority.pp')

class { '::nsxv::repo_priority':
  plugin_name    => "nsxv",
  plugin_version => "1.0.0",
}
