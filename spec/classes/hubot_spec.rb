require 'spec_helper'

describe 'hubot', :type => :class do
  let(:pre_condition) { 'class nodejs {}' }

  it { should create_class('hubot') }
  pending "make me test things"

end

