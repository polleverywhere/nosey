require 'spec_helper'

describe Nosey::Instrumentation do
  before(:each) do
    @instance = Nosey::Test::VanillaClass.new
  end

  it "should have nosey Probe::Set instance" do
    @instance.nosey.should be_instance_of Nosey::Probe::Set
  end
end