require 'spec_helper'

describe 'hubot::script', :type => :define do
  let(:facts) { { :operatingsystem => 'RedHat' } }
  let(:title) { 'myscript.coffee' }
  let(:params) { { :source => 'puppet:///data/hubot/myscript.coffee' } }

  it { should contain_file('/opt/hubot/hubot/scripts/myscript.coffee').with_source('puppet:///data/hubot/myscript.coffee') }

  context 'with git_source' do
    let(:pre_condition) { [ 'class hubot { $git_source = true }', 'include riak' ] }
    it { expect { should raise_error(Puppet::Error) } }
  end

end
