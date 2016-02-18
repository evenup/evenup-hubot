require 'spec_helper'

describe 'hubot', :type => :class do
  let(:facts) { { :operatingsystem => 'RedHat', :osfamily => 'RedHat', :operatingsystemrelease => '7.0' } }
  let(:pre_condition) { "class nodejs ( $manage_package_repo = false) {}" }

  it { should create_class('hubot') }
  it { should contain_class('hubot::install') }
  it { should contain_class('hubot::config') }
  it { should contain_class('hubot::service') }
  it { should contain_class('nodejs').with_manage_package_repo(false) }

  describe 'without nodejs' do
    let(:params) { { :install_nodejs => false } }
  it { should_not contain_class('nodejs') }
  end

  describe 'install hubot' do
    it { should contain_group('hubot') }
    it { should contain_user('hubot').with_home('/opt/hubot') }
    it { should contain_package('hubot').with_provider('npm') }
    it { should contain_package('coffee-script').with_provider('npm') }
    it { should contain_file('/etc/init.d/hubot').with_content %r{^\. /etc/init.d/functions$} }

    context 'override root_dir' do
      let(:params) { { :root_dir => '/var/hubot' } }
      it { should contain_user('hubot').with_home('/var/hubot') }
    end

    context 'with build_deps (string)' do
      let(:params) { { :build_deps => 'dep1' } }
      it { should contain_package('dep1') }
    end

    context 'with build_deps (array)' do
      let(:params) { { :build_deps => [ 'dep1', 'dep2' ] } }
      it { should contain_package('dep1') }
      it { should contain_package('dep2') }
    end
  end # install

  describe 'install hubot (Ubuntu)' do
    let :facts do
      {
        :operatingsystem => 'Ubuntu',
        # extra facts to satisfy puppetlabs/nodejs and puppetlabs/apt
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu',
        :lsbdistcodename => 'precise',
      }
    end
    it { should contain_class('nodejs').with_manage_package_repo(true).that_comes_before('Package[hubot]') }
    it { should contain_file('/etc/init.d/hubot').with_content %r{^\. /lib/lsb/init-functions$} }
  end #install on Ubungu

  context 'configure hubot' do
    it { should contain_file('/etc/init.d/hubot') }

    context 'via git_source' do
      let(:params) { { :git_source => 'git@git.mycompany.com:hubot.git' } }

      it { should contain_class('git') }
      it { should contain_file('/opt/hubot/.ssh') }
      it { should contain_file('/opt/hubot/.ssh/id_rsa') }
      it { should contain_file('/opt/hubot/.ssh/config') }
      it { should contain_vcsrepo('/opt/hubot/hubot').with_source('git@git.mycompany.com:hubot.git') }
      it { should_not contain_exec('Hubot init') }
      it { should_not contain_file('/opt/hubot/hubot/hubot.env')}
      it { should_not contain_file('/opt/hubot/hubot/hubot-scripts.json')}
      it { should_not contain_file('/opt/hubot/hubot/external-scripts.json')}
      it { should_not contain_file('/opt/hubot/hubot/package.json')}

      context 'changing root_dir' do
        let(:params) { { :git_source => 'git@git.mycompany.com:hubot.git', :root_dir => '/var/hubot' } }
        it { should contain_file('/var/hubot/.ssh') }
        it { should contain_file('/var/hubot/.ssh/id_rsa') }
        it { should contain_file('/var/hubot/.ssh/config') }
        it { should contain_vcsrepo('/var/hubot/hubot') }
      end

      context 'disable auto_accept_host_key' do
        let(:params) { { :git_source => 'git@git.mycompany.com:hubot.git', :auto_accept_host_key => false } }
        it { should_not contain_file('/opt/hubot/.ssh/config') }
      end

      context 'change bot name' do
        let(:params) { { :git_source => 'git@git.mycompany.com:hubot.git', :bot_name => 'foobot' } }
        it { should contain_vcsrepo('/opt/hubot/foobot') }
      end

      context 'specify environment variables' do
        let(:params) { { :env_export => { 'test1' => 'test value 1' } } }
        it { should contain_file('/opt/hubot/hubot/hubot.env') }
      end
    end # git_source

    context 'no git_source' do
      it { should contain_exec('Hubot init').with(
        :command  => 'hubot -c hubot',
        :cwd      => '/opt/hubot',
        :unless   => 'test -d /opt/hubot/hubot'
      ) }
      it { should contain_file('/opt/hubot/hubot/hubot.env')}
      it { should contain_file('/opt/hubot/hubot/hubot-scripts.json')}
      it { should contain_file('/opt/hubot/hubot/external-scripts.json')}
      it { should contain_file('/opt/hubot/hubot/package.json')}

      context 'changing root_dir' do
        let(:params) { { :root_dir => '/var/hubot' } }
        it { should contain_exec('Hubot init').with(
          :cwd      => '/var/hubot',
          :unless   => 'test -d /var/hubot/hubot'
        ) }
        it { should contain_file('/var/hubot/hubot/hubot.env')}
        it { should contain_file('/var/hubot/hubot/hubot-scripts.json')}
        it { should contain_file('/var/hubot/hubot/external-scripts.json')}
        it { should contain_file('/var/hubot/hubot/package.json')}
      end

      context 'changing bot_name' do
        let(:params) { { :bot_name => 'foobot' } }
        it { should contain_exec('Hubot init').with(
          :command  => 'hubot -c foobot',
          :unless   => 'test -d /opt/hubot/foobot'
        ) }
        it { should contain_file('/opt/hubot/foobot/hubot.env')}
        it { should contain_file('/opt/hubot/foobot/hubot-scripts.json')}
        it { should contain_file('/opt/hubot/foobot/external-scripts.json')}
        it { should contain_file('/opt/hubot/foobot/package.json')}
      end
    end # no git_source
  end # configure

  context 'manage hubot service' do
    context 'no adapter' do
      it { should contain_service('hubot').with_ensure('stopped').with_enable(false) }
    end

    context 'adapter set' do
      let(:params) { { :adapter => 'hipchat' } }
      it { should contain_service('hubot').with_ensure('running').with_enable(true) }

      context 'ensure stopped' do
        let(:params) { { :adapter => 'hipchat', :service_ensure => 'stopped' } }
        it { should contain_service('hubot').with_ensure('stopped') }
      end

      context 'enable false' do
        let(:params) { { :adapter => 'hipchat', :service_enable => false } }
        it { should contain_service('hubot').with_enable(false) }
      end
    end # adapter
  end #service

end

