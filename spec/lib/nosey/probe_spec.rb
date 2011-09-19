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

  it "should reset" do
    @probes.touch('barf')
    @probes.reset
    @probes.probe('barf').value.should be_nil
  end

  it "should return report" do
    @probes.report.probe_sets.first.should eql(@probes)
  end
end

describe Nosey::Probe::Sum do
  before(:all) do
    @sum = Nosey::Probe::Sum.new
  end

  it "should sum" do
    @sum.sample(1)
    @sum.sample(2)
    @sum.value.should eql(3)
  end

  it "should reset" do
    @sum.sample(1)
    @sum.sample(2)
    @sum.reset
    @sum.value.should be_nil
  end
end

describe Nosey::Probe::Maximum do
  before(:all) do
    @max = Nosey::Probe::Maximum.new
  end

  it "should know max" do
    @max.sample(1)
    @max.sample(3)
    @max.value.should eql(3)
  end

  it "should reset" do
    @max.sample(1)
    @max.reset
    @max.value.should be_nil
  end
end

describe Nosey::Probe::Minimum do
  before(:all) do
    @min = Nosey::Probe::Minimum.new
  end

  it "should know max" do
    @min.sample(1)
    @min.sample(2)
    @min.value.should eql(1)
  end

  it "should reset" do
    @min.sample(2)
    @min.reset
    @min.value.should be_nil
  end
end

describe Nosey::Probe::Average do
  before(:all) do
    @avg = Nosey::Probe::Average.new
  end

  it "should know avg" do
    @avg.sample(1)
    @avg.sample(2)
    @avg.value.should eql(1.5)
  end

  it "should reset" do
    @avg.sample(1)
    @avg.sample(2)
    @avg.reset
    @avg.value.should be_nil
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

  it "should reset" do
    @counter.increment(1)
    @counter.reset
    @counter.value.should be_nil
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