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

  it "should avg" do
    @probes.avg('foobers', 1)
  end

  it "should sum" do
    @probes.sum('foobers', 1)
  end

  it "should max" do
    @probes.max('foobers', 1)
  end

  it "should min" do
    @probes.max('foobers', 1)
  end

  it "should get probe" do
    @probes.touch('barf')
    @probes.probe('barf').should be_instance_of(Nosey::Probe::Touch)
  end

  it "should return report" do
    @probes.report.probe_sets.first.should eql(@probes)
  end
end

describe Nosey::Probe do
  it "should calculate sum" do
    sum = Nosey::Probe::Sum.new
    sum.sample(1)
    sum.sample(2)
    sum.value.should eql(3)
  end

  it "should calculate max" do
    max = Nosey::Probe::Maximum.new
    max.sample(1)
    max.sample(3)
    max.value.should eql(3)
  end

  it "should calculate minimum" do
    min = Nosey::Probe::Minimum.new
    min.sample(1)
    min.sample(2)
    min.value.should eql(1)
  end

  it "should calculate average" do
    avg = Nosey::Probe::Average.new
    avg.sample(1)
    avg.sample(2)
    avg.value.should eql(1.5)
  end
end

describe Nosey::Probe::Count do
  before(:all) do
    @counter = Nosey::Probe::Count.new
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