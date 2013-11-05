#
class hubot::install {

  group { 'hubot':
    ensure  => 'present',
    system  => true,
  }

  user { 'hubot':
    ensure      => present,
    comment     => 'Hubot Service User',
    system      => true,
    gid         => 'hubot',
    home        => $hubot::root_dir,
    shell       => '/bin/bash',
    managehome  => true,
    require     => Group['hubot'],
  }

  if $hubot::ssh_pubkey {
    ssh_authorized_key { 'hubot':
      ensure  => 'present',
      user    => 'hubot',
      key     => $hubot::ssh_pubkey,
      type    => 'ssh-rsa',
    }
  }

  if $hubot::build_deps {
    package { $hubot::build_deps:
      ensure  => 'installed',
      before  => [ Package['hubot'], Package['coffee-script'] ]
    }
  }

  package { ['hubot', 'coffee-script']:
    ensure    => 'installed',
    require   => User['hubot'],
    provider  => 'npm',
    notify    => Class['hubot::config'],
  }

}
