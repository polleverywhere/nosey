require 'eventmachine'
require 'strscan'

module EventMachine
  module Nosey
    class SocketServer < EventMachine::Connection
      Host = '/tmp/nosey.socket'
      Port = nil
      CommandPattern = /[A-Z]+\n/

      attr_accessor :report

      # Accept a collection of aggregators that we'll use to report our stats.
      def initialize(report)
        @report = report
      end

      def receive_data(data)
        buffer << data
        # Look for commands in the buffer and process them
        # TODO - For higher performance, queue this in a Em::Queue
        while command = buffer.scan(CommandPattern)
          process_command command
        end
      end

      def process_command(command)
        case command.strip
        when 'READ' # This is for more normal uses cases where you want to watch stats
          send_data report.to_s
        when 'RESET' # This is used primarly by munin, or other tools that can't track state.
          send_data report.to_s
          report.reset
        when 'QUIT'
          close_connection_after_writing
        else
          send_data "No Comprende. READ, RESET, o QUIT."
        end
      end

      # A nice short-cut for peeps who aren't familar with EM to fire up
      # an Reporting server with an array of aggregators, host, and a port.
      def self.start(report, host=SocketServer::Host, port=SocketServer::Port)
        EventMachine::start_server(host, port, self, report)
      end

    private
      def buffer
        @buffer ||= StringScanner.new("")
      end
    end
  end
end