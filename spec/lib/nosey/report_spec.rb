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
    Psych.load(@report.to_s)['Group 2'].keys.should include('generated-at')
  end
end