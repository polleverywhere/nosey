require 'spec_helper'

describe Nosey::Probe::Set do
  before(:each) do
    @probes = Nosey::Probe::Set.new("My Probe Set")
  end

  it "should have name" do
    @probes.name.should eql("My Probe Set")
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

  it "should sample" do
    @probes.sample('foobers', 1).should be_instance_of(Hash)
  end

  it "should get probe" do
    @probes.touch('barf')
    @probes.probe('barf').should be_instance_of(Nosey::Probe::Touch)
  end

  it "should return report" do
    @probes.report.probe_sets.first.should eql(@probes)
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

describe Nosey::Probe::Sampler do
  before(:each) do
    @counter = Nosey::Probe::Sampler.new
    @counter.sample 1
    @counter.sample 2
    @counter.sample 3
  end

  it "should init hash" do
    @counter.value.should be_instance_of(Hash)
  end

  it "should have avg" do
    @counter.value['avg'].should eql(2)
  end

  it "should have sum" do
    @counter.value['sum'].should eql(6)
  end

  it "should have min" do
    @counter.value['min'].should eql(1)
  end

  it "should have max" do
    @counter.value['max'].should eql(3)
  end

  it "should have count" do
    @counter.value['count'].should eql(3)
  end
end