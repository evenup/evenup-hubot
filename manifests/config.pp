#
class hubot::config {

  $exports = $hubot::env_export
  $scripts = $hubot::scripts
  $external_scripts = $hubot::external_scripts
  $dependencies = $hubot::dependencies
  file { '/etc/init.d/hubot':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    content => template('hubot/hubot.init.erb'),
    notify  => Class['hubot::service']
  }

  if $hubot::git_source {
    require 'git'

    if !defined(File["${hubot::root_dir}/.ssh"]) {
      file { "${hubot::root_dir}/.ssh":
        ensure  => 'directory',
        owner   => 'hubot',
        group   => 'hubot',
        mode    => '0700',
      }
    }

    if !defined(File["${hubot::root_dir}/.ssh/id_rsa"]) {
      file { "${hubot::root_dir}/.ssh/id_rsa":
        ensure  => 'file',
        owner   => 'hubot',
        group   => 'hubot',
        mode    => '0600',
        content => $hubot::ssh_privatekey,
        source  => $hubot::ssh_privatekey_file,
      }
    }

    # If your hubot config is stored in git (it is, right?), this will clone
    # it to this machine.  This assumes you have already configured any keys
    # and access needed.  Alternatively, most config can be done through puppet
    exec { 'hubot git clone':
      command => "git clone ${hubot::git_source} ${hubot::root_dir}/${hubot::bot_name}",
      unless  => "test -d ${hubot::root_dir}/${hubot::bot_name}",
      user    => 'hubot',
      group   => 'hubot',
      path    => '/usr/bin/',
      require => Class['hubot::install'],
    }
  } else {
    exec { 'Hubot init':
      command     => "hubot -c ${hubot::bot_name}",
      cwd         => $hubot::root_dir,
      path        => '/usr/bin',
      unless      => "test -d ${hubot::root_dir}/${hubot::bot_name}",
      user        => 'hubot',
      group       => 'hubot',
      logoutput   => 'on_failure',
    }

    file { "${hubot::root_dir}/${hubot::bot_name}/hubot.env":
      ensure  => 'present',
      owner   => 'hubot',
      group   => 'hubot',
      mode    => '0440',
      content => template('hubot/hubot.env.erb'),
      notify  => Class['hubot::service'],
      require => Exec['Hubot init'],
    }

    file { "${hubot::root_dir}/${hubot::bot_name}/hubot-scripts.json":
      ensure  => 'present',
      owner   => 'hubot',
      group   => 'hubot',
      mode    => '0444',
      content => template('hubot/hubot-scripts.erb'),
      notify  => Class['hubot::service'],
      require => Exec['Hubot init'],
    }

    file { "${hubot::root_dir}/${hubot::bot_name}/external-scripts.json":
      ensure  => 'present',
      owner   => 'hubot',
      group   => 'hubot',
      mode    => '0444',
      content => template('hubot/external-scripts.erb'),
      notify  => Class['hubot::service'],
      require => Exec['Hubot init'],
    }

    file { "${hubot::root_dir}/${hubot::bot_name}/package.json":
      ensure  => 'present',
      owner   => 'hubot',
      group   => 'hubot',
      mode    => '0444',
      content => template('hubot/package.json.erb'),
      notify  => Class['hubot::service'],
      require => Exec['Hubot init'],
    }

  }

}
