class nsxv::repo_priority (
  $plugin_name,
  $plugin_version,
) {
  if $operatingsystem == 'Ubuntu' {
    include apt

    $pref_file = "/etc/apt/preferences.d/${plugin_name}-${plugin_version}.pref"
    $source_file = "/etc/apt/sources.list.d/${plugin_name}-${plugin_version}.list"
    $target_file = "/etc/apt/sources.list.d/1-${plugin_name}.list"

    file_line { 'change_priority_to_nsxv_repo ':
      path   => $pref_file,
      line   => 'Pin-Priority: 500',
      match  => '^\s*Pin-Priority.*$',
      notify => Exec['apt_update']
    }
    exec { "rename_nsxv_repo_file":
      path      => '/usr/bin:/usr/sbin:/bin',
      command   => "mv -f ${source_file} ${target_file}",
      onlyif    => "test ! -e ${target_file}",
      provider  => shell,
      tries     => 3,
      try_sleep => 10,
      notify    => Exec['apt_update']
    }
  }
}
