require 'spec_helper'

describe Nosey::Munin::Graph do
  before(:each) do
    @report = Nosey::Report.new do |r|
      3.times do |n| 
        r.probe_sets << Nosey::Probe::Set.new("Group #{n}") do |s|
          s.touch 'generated-at'
          s.increment 'hit'
          s.sample 'chopper', 2
        end
      end
    end

    @graph = Nosey::Munin::Graph.new(@report.to_s) do |g|
      g.title = "Test Graph"
      g.vertical_label = "Response times"
    end
  end

  context "configuration" do
    before(:each) do
      @text = @graph.configure
    end

    it "should have title" do
      @text.scan(/graph_title Test Graph/).should have(1).item
    end

    it "should have default App category" do
      @text.scan(/graph_category App/).should have(1).item
    end

    it "should have a vertical axis label" do
      @text.scan(/graph_vlabel Response times/).should have(1).item
    end

    it "should have labels" do
      @text.scan(/[A-Za-z0-9_]+\.label .+\n/).should have(7).items
    end
  end

  context "sample" do
    before(:each) do
      @text = @graph.sample
    end

    it "should have values" do
      @text.scan(/[A-Za-z0-9_]+\.value .+\n/).should have(7).items
    end
  end
end