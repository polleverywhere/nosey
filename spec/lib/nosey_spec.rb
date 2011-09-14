require 'spec_helper'

describe Nosey::Report do
  before(:each) do
    @report = Nosey::Report.new(*(1..3).map{ Nosey::Probes.new })
  end
end

describe Nosey::Probes do
  before(:each) do
    @probes = Nosey::Probes.new
  end

  it "should increment" do
    @probes.increment('count').should eql(1)
  end

  it "should decrement" do
    @probes.decrement('count').should eql(-1)
  end

  it "should touch" do
    @probes.touch('touched-at').should be_instance_of(Time)
  end

  it "should get probe" do
    @probes.touch('barf')
    @probes.probe('barf').should be_instance_of(Nosey::Probe::Touch)
  end
end

describe Nosey::Probe::Counter do
  before(:all) do
    @counter = Nosey::Probe::Counter.new
  end

  it "should init null" do
    @counter.value.should be_nil
  end

  it "should increment" do
    @counter.increment.should eql(1)
  end

  it "should decrement" do
    @counter.decrement(2).should eql(-1)
  end

  it "should set" do
    @counter.set(0).should eql(0)
  end
end

describe Nosey::Probe::Touch do
  before(:all) do
    @touch = Nosey::Probe::Touch.new
  end
  it "should init null" do
    @touch.value.should be_nil
  end

  it "should touch" do
    @touch.touch
    @touch.value.should_not be_nil
  end
end

describe Nosey::Instrumentation do
  before(:each) do
    @instance = Nosey::Test::VanillaClass.new
  end

  it "should have nosey Probes instance" do
    @instance.nosey.should be_instance_of Nosey::Probes
  end
end