# == Definition: hubot::script
#
# Installs a custom script when not using git_source
#
#
# === Parameters
#
# [*source*]
#   String.  Puppet source of the script
#   Required.
#
# [*script_name*]
#   String.  Name of the script to be installed.
#   Default: $name
#
#
#
# === Examples
#
#   hubot::script { 'myscript.coffee': source => 'puppet:///data/hubot/myscript.coffee' }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
define hubot::script(
  $source,
  $script_name = undef,
) {

  include ::hubot

  if $::hubot::git_source {
    fail ('hubot::script cannot be used with git_source')
  }

  if $script_name {
    $name_real = $script_name
  } else {
    $name_real = $name
  }

  file { "${::hubot::root_dir}/${::hubot::bot_name}/scripts/${name_real}":
    ensure  => 'file',
    owner   => 'hubot',
    group   => 'hubot',
    mode    => '0444',
    source  => $source,
    require => Class['hubot::config'],
  }

}
