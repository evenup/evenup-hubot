# == Class: hubot::install
#
# Installs hubot
# Private class
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
class hubot::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  group { 'hubot':
    ensure => present,
    system => true,
  }

  user { 'hubot':
    ensure     => present,
    comment    => 'Hubot Service User',
    system     => true,
    gid        => 'hubot',
    home       => $::hubot::root_dir,
    shell      => '/bin/bash',
    managehome => true,
    require    => Group['hubot'],
  }

  file { $::hubot::root_dir:
    ensure  => directory,
    owner   => 'hubot',
    group   => 'hubot',
    mode    => '0644',
    require => User['hubot'],
  }

  if $::hubot::build_deps {
    ensure_resource('package', $::hubot::build_deps, { ensure => 'installed' })
  }

  $version = $::hubot::hubot_version ? {
    ''      => 'present',
    default => $::hubot::hubot_version,
  }

  package { 'hubot':
    ensure   => $version,
    require  => [
                  User['hubot'],
                  Package[$::hubot::build_deps],
    ],
    provider => 'npm',
  }

  ensure_resource('package', 'coffee-script', {
    ensure   => present,
    require  => Package['hubot'],
    provider => 'npm'
  })
}
