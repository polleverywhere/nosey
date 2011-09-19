require 'eventmachine'

module EventMachine
  module Nosey
    class SocketServer < EventMachine::Connection
      Host = '/tmp/nosey.socket'
      Port = nil

      attr_accessor :report

      # Accept a collection of aggregators that we'll use to report our stats.
      def initialize(report)
        @report = report
      end

      def receive_data(data)
        buffer << data
        # Stop buffering if a newline is detected and process command
        process_command buffer.strip if data =~ /\n/
      end

      def process_command(command)
        case command
        when 'READ' # This is for more normal uses cases where you want to watch stats
          send_data report.to_s
        when 'RESET' # This is used primarly by munin, or other tools that can't track state.
          send_data report.to_s
          report.reset
        else
          send_data "No Comprende. send 'read' to see stats or 'reset' to read and reset."
        end
        close_connection_after_writing
      end

      # A nice short-cut for peeps who aren't familar with EM to fire up
      # an Reporting server with an array of aggregators, host, and a port.
      def self.start(report, host=SocketServer::Host, port=SocketServer::Port)
        EventMachine::start_server(host, port, self, report)
      end

    private
      def buffer
        @buffer ||= ""
      end
    end
  end
end