#
class hubot (
  $env_export           = $::hubot::params::env_export,
  $scripts              = $::hubot::params::scripts,
  $external_scripts     = $::hubot::params::external_scripts,
  $dependencies         = $::hubot::params::dependencies,
  $root_dir             = $::hubot::params::root_dir,
  $bot_name             = $::hubot::params::bot_name,
  $display_name         = $::hubot::params::name,
  $log_file             = $::hubot::params::log_file,
  $adapter              = $::hubot::params::adapter,
  $git_source           = $::hubot::params::git_source,
  $ssh_privatekey       = $::hubot::params::ssh_privatekey,
  $ssh_privatekey_file  = $::hubot::params::ssh_privatekey_file,
  $build_deps           = $::hubot::params::build_deps,
) inherits hubot::params {

  if $log_file {
    $log_file_real = $log_file
  } else {
    $log_file_real = "/var/log/${bot_name}"
  }

  require 'nodejs'

  class { 'hubot::install': }
  class { 'hubot::config': }
  class { 'hubot::service': }

  # Containment
  anchor { 'hubot::begin': } ->
  Class['hubot::install'] ->
  Class['hubot::config'] ~>
  Class['hubot::service'] ->
  anchor { 'hubot::end': }

}
