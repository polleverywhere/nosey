require 'spec_helper'

describe EventMachine::Nosey::SocketServer do
  include EM::Ventually

  before(:each) do
    @report = Nosey::Report.new do |r|
      3.times do |n| 
        r.probe_sets << Nosey::Probe::Set.new("Group #{n}") do |set|
          set.increment 'hit'
          set.touch 'generated-at'
          set.sample 'zie-number', 1
        end
      end
    end
  end

  it "should write report to socket" do
    EventMachine::Nosey::SocketServer.start @report
    Nosey::Test::ReadSocket.start('/tmp/nosey.socket').callback{|data|
      @response = data
    }
    ly{ @response }.test{|response| YAML.load(response).is_a?(Hash) }
  end
end