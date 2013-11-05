#
class hubot::params {
  $env_export           = {}
  $scripts              = []
  $external_scripts     = []
  $dependencies         = { 'hubot' => '>= 2.6.0 < 3.0.0', 'hubot-scripts' => '>= 2.5.0 < 3.0.0' }
  $root_dir             = '/opt/hubot'
  $bot_name             = 'hubot'
  $display_name         = 'hubot'
  $log_file             = undef
  $adapter              = 'shell'
  $git_source           = undef
  $ssh_privatekey       = undef
  $ssh_privatekey_file  = undef
  $build_deps           = []
}
