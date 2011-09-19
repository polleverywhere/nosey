require 'nosey'
require 'em-ventually'
require 'socket'

module Nosey
  module Test
    class VanillaClass
      include Nosey::Instrumentation

      def count
        nosey.count('count')
      end

      def touch
        nosey.touch('touched-at')
      end
    end

    # Read data from a socket and then kill it right away.
    class ReadSocket < EventMachine::Connection
      include EventMachine::Deferrable

      def receive_data(data)
        buffer << data
      end

      def unbind
        succeed buffer
      end

      def self.start(host,port=nil)
        EventMachine::connect(host, port, self)
      end

    private
      def buffer
        @buffer ||= ""
      end
    end
  end
end