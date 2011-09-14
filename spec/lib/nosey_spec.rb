require 'spec_helper'

describe Nosey::Report do
  before(:each) do
    @report = Nosey::Report.new do |r|
      3.times do |n| 
        r.probe_sets << Nosey::Probe::Set.new("Group #{n}") do |set|
          set.touch 'generated-at'
          set.increment 'hit'
        end
      end
    end
  end

  context "report hash" do
    it "should have groups" do
      @report.to_hash.keys.should include('Group 0', 'Group 1', 'Group 2')
    end

    it "should have probes" do
      @report.to_hash['Group 1'].keys.should include('generated-at', 'hit')
    end
  end
  
  it "should generate report YML for string" do
    # Spot check for a probe key
    YAML.load(@report.to_s)['Group 2'].keys.should include('generated-at')
  end
end

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

describe Nosey::Instrumentation do
  before(:each) do
    @instance = Nosey::Test::VanillaClass.new
  end

  it "should have nosey Probe::Set instance" do
    @instance.nosey.should be_instance_of Nosey::Probe::Set
  end
end