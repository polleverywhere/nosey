require 'spec_helper'

describe Nosey::Munin::Graph do
  before(:each) do
    @report = Nosey::Report.new do |r|
      3.times do |n| 
        r.probe_sets << Nosey::Probe::Set.new("Group #{n}") do |s|
          s.touch 'generated-at'
          s.increment 'hit'
          s.avg 'chopper-avg', 2
          s.min 'chopper-min', 2
          s.max 'chopper-max', 2
          s.sum 'chopper-sum', 2
        end
      end
    end

    @graph = Nosey::Munin::Graph.new(@report.to_s) do |g|
      g.title = "Test Graph"
      g.vertical_label = "Response times"
      g.labels = {"min" => "Min", "max" => "Max", "avg" => "Avg"}
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
      @text.scan(/[A-Za-z0-9_]+\.label .+\n/).should have(3).items
    end
  end

  it "should filter" do
    @graph.filter do |name|
      name =~ /chopper-sum|chopper-avg/
    end
    @graph.munin_hash.should have(2).items
  end

  context "sample" do
    before(:each) do
      @text = @graph.sample
    end

    it "should have values" do
      @text.scan(/[A-Za-z0-9_]+\.value .+\n/).should have(6).items
    end
  end

  context "munin client" do
    def graph(report, *argv)
      out = StringIO.new

      Nosey::Munin.graph argv, out do |g|
        g.data report.to_s
        g.category 'Bananas'
        g.title 'Fruit Fly Charts'
        g.vertical_label 'Wing speed (beats per second'
        g.labels ({"min" => "min"})
      end

      out.rewind
      out.read
    end

    it "should configure" do
      graph(@report, 'config').should match(/graph_title Fruit Fly Charts/)
    end

    it "should sample" do
      graph(@report).should match(/chopper_avg\.value \d+/)
    end

    it "should read from socket"
  end
end