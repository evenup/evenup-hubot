# == Class: hubot
#
# Puppet module to install a hubot (http://hubot.github.com/) bot and either a
# basic config based on parameters to get you up and running/testing, or a
# config stored in a git repo.
#
#
# === Parameters
#
# [*root_dir*]
#   String.  Root directory for hubot bots (also the hubot user's home dir)
#   Default: /opt/hubot
#
# [*bot_name*]
#   String.  Passed as the -c parameter to hubot.  Directory name inside $root_dir for your bot
#   Default: hubot
#
# [*display_name*]
#   String.  The name this bot should present itself to users as
#   Default: hubot
#
# [*build_deps*]
#   String/Array of Strings.  Any additional packages that should be installed to
#     support building npm, nodejs, or any npm modules from 'npm install'
#   Default: []
#
# [*env_export*]
#   Hash. Used when not using git_source.  Contains a list of environment variables
#     that should be exported for this bot
#   Default: {}
#
# [*scripts*]
#   Array of Strings. Used when not using git_source.  List of scripts to be
#     included from hubot-scripts
#   Default: []
#
# [*log_file*]
#   String.  Name of the logfile to log to
#   Default: /var/log/$bot_name
#
# [*adapter*]
#   String.  Adapter to use for the bot.  The default (shell) will cause the service
#     to be set to stopped and disabled.
#   Default: shell
#
# [*dependencies*]
#   Hash.  Used when not using git_source.  List of dependencies to be included
#     in package.json for 'npm install'
#
# [*git_source*]
#   String.  Source path to the git repo containing the bot's config (recommended)
#   Default: undef
#
# [*ssh_privatekey*]
#   String.  Contents of the SSH private key (if needed) for git_source
#   Default: undef
#
# [*ssh_privatekey_file*]
#   String.  Puppet source to the SSH private key (if needed) for git_source
#   Default: undef
#
# [*auto_accept_host_key*]
#   Boolean.  Whether or not StrictHostKeyChecking should be disable for the
#     hubot user.  NOTE: this disables it for "host *" rather than a crazy
#     regexp/match based off of git_source
#   Default: true
#
# [*service_ensure*]
#   String.  Value to apply to the hubot service.  NOTE: See $adapter for exception
#   Default: running
#
# [*service_enable*]
#   Boolean.  Enable service at boot?  NOTE: see $adapter for exception
#   Default: true
#
# [*nodejs_manage_repo*]
#   Boolean. Allow the nodejs module to manage the repository it gets installed from.
#     Default is True for Debian, False for everyone else.
#
# === Examples
#
#   class { 'hubot':
#     bot_name      => 'mybot',
#     display_name  => 'Foo Bot',
#     adapter       => 'hipchat',
#     build_deps    => [ 'libxml2-devel', 'gcc-c++' ],
#     env_export    => { 'HUBOT_LOG_LEVEL'        => 'DEBUG',
#                        'HUBOT_HIPCHAT_ROOMS'    => 'xmpp_room1@conf.hipchat.com,xmpp_room2@conf.hipchat.com',
#                        'HUBOT_HIPCHAT_JID'      => 'hubot_jid@chat.hipchat.com',
#                       'HUBOT_HIPCHAT_PASSWORD' => 'hubot_pass'
#                       },
#     scripts       => ["redis-brain.coffee", "devexcuse.coffee", "reload.coffee", "script.coffee", "setenv.coffee" ],
#     dependencies  => { "hubot" => ">= 2.6.0 < 3.0.0", "hubot-scripts" => ">= 2.5.0 < 3.0.0", "cheerio" => "*", "hubot-hipchat" => "~2.5.1-5" },
#   }
#
#   class { 'hubot':
#     git_source          => 'git@git.mycompany.com:hubot',
#     ssh_privatekey_file => 'puppet:///data/ssh/hubot_id_rsa,
#    }
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
class hubot (
  $hubot_version        = $::hubot::params::hubot_version,
  $root_dir             = $::hubot::params::root_dir,
  $bot_name             = $::hubot::params::bot_name,
  $display_name         = $::hubot::params::display_name,
  $build_deps           = $::hubot::params::build_deps,
  $env_export           = $::hubot::params::env_export,
  $scripts              = $::hubot::params::scripts,
  $external_scripts     = $::hubot::params::external_scripts,
  $log_file             = $::hubot::params::log_file,
  $adapter              = $::hubot::params::adapter,
  $dependencies         = $::hubot::params::dependencies,
  $git_source           = $::hubot::params::git_source,
  $ssh_privatekey       = $::hubot::params::ssh_privatekey,
  $ssh_privatekey_file  = $::hubot::params::ssh_privatekey_file,
  $auto_accept_host_key = $::hubot::params::auto_accept_host_key,
  $service_ensure       = $::hubot::params::service_ensure,
  $service_enable       = $::hubot::params::service_enable,
  $nodejs_manage_repo   = $::hubot::params::nodejs_manage_repo,
) inherits hubot::params {

  if $log_file {
    $log_file_real = $log_file
  } else {
    $log_file_real = "/var/log/${bot_name}.log"
  }

  if $adapter == 'shell' {
    $service_ensure_real = stopped
    $service_enable_real = false
  } else {
    $service_ensure_real = $service_ensure
    $service_enable_real = $service_enable
  }
  class { 'nodejs':
    manage_repo => $nodejs_manage_repo,
  }

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
