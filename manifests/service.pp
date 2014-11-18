# == Class: hubot::service
#
# Manages the hubot service
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
class hubot::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { 'hubot':
    ensure     => $::hubot::service_ensure_real,
    enable     => $::hubot::service_enable_real,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['hubot::config'],
  }

}
