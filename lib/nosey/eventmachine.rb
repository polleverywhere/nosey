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

      # Dump out the stats and close down the connection
      def post_init
        begin
          send_data report.to_s
        rescue => e
          send_data "Exception! #{e}\n#{e.backtrace}"
        ensure
          close_connection
        end
      end

      # A nice short-cut for peeps who aren't familar with EM to fire up
      # an Reporting server with an array of aggregators, host, and a port.
      def self.start(report, host=SocketServer::Host, port=SocketServer::Port)
        EventMachine::start_server(host, port, self, report)
      end
    end
  end
end