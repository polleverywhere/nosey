require 'spec_helper'
require 'yaml'

describe EventMachine::Nosey::SocketServer do
  include EM::Ventually

  before(:each) do
    @report = Nosey::Report.new do |r|
      3.times do |n| 
        r.probe_sets << Nosey::Probe::Set.new("Group #{n}") do |set|
          set.increment 'hit'
          set.increment 'hit'
          set.touch 'generated-at'
          set.avg 'zie-number-avg', 1
        end
      end
    end
  end

  it "should read report data with READ command" do
    EventMachine::Nosey::SocketServer.start @report
    socket = Nosey::Test::ReadSocket.start('/tmp/nosey.socket')
    socket.callback{|data|
      @resp = data
    }
    socket.send_data("READ\n")

    ly{2}.test{|count| YAML.load(@resp)['Group 0']['hit'] == count }
  end

  it "should reset report and read data with RESET command" do
    @r1 = @r2 = nil

    EventMachine::Nosey::SocketServer.start @report
    
    s1 = Nosey::Test::ReadSocket.start('/tmp/nosey.socket')
    s2 = Nosey::Test::ReadSocket.start('/tmp/nosey.socket')

    s1.send_data("RESET\n")
    s1.callback{|data|
      @r1 = data
      s2.send_data("READ\n")
      s2.callback{|data|
        @r2 = data
      }
    }

    ly{nil}.test{|count| YAML.load(@r2)['Group 0']['hit'] == count }
  end
end