require 'socket'
require 'yaml'
require 'stringio'

module Nosey
  module Munin
    # Various commands available to munin
    module Argument
      Configuration = 'config'
    end

    # Print the output of the munin graph to $stdout
    def self.graph(args=ARGV,out=$stdout,&block)
      graph = Graph::DSL.new(&block).graph

      # Munin passes configure into this to figure out the graph.
      out.puts case args.first
      when Argument::Configuration
        graph.configure
      else
        graph.sample
      end
    end

    # Parse a Nosey socket for Munin
    class Graph
      attr_accessor :data, :title, :vertical_label, :category
      attr_writer :probe_set

      def initialize(data=nil)
        @data = data
        @category = 'App' # Default it to app duuude
        yield self if block_given?
        self
      end

      # Munin calls this to setup the title and labels for the chart
      # graph_title THE TITLE OF YOUR GRAPH
      # graph_category THE CATEGORY / GROUP OF YOUR GRAPH
      # graph_vlabel Count
      # total.label Total
      # other.label Other
      def configure
        body = StringIO.new
        body.puts "graph_title #{title}"
        body.puts "graph_category #{category}"
        body.puts "graph_vlabel #{vertical_label}"
        munin_hash.each do |field, (label, value)|
          body.puts "#{field}.label #{label}"
        end
        body.rewind
        body.read
      end

      # Munin calls this to set the values in the chart
      # total.value 0
      # other.value 2
      def sample
        body = StringIO.new
        munin_hash.each do |field, (label, value)|
          body.puts "#{field}.value #{value}"
        end
        body.rewind
        body.read
      end

      def munin_hash(root_key=nil,hash=self.probe_set)
        # TODO perform processing for more complicated probes, like samplers, etc
        hash.reduce({}) do |memo, (name, value)|
          case value
          when Hash # Its nested, go deep! Oooo yeah!
            munin_hash(format_field(root_key, name), value).each do |name, value|
              memo[format_field(root_key, name)] = value.to_a
            end
          else # Its cool, return this mmmkay? Sheesh man
            memo[format_field(root_key, name)] = [name, value]
          end
          memo
        end
      end

      # Default to the first probeset if nothing is specified
      def probe_set
        report[@probe_set ||= report.keys.first]
      end

      def title
        @title ||= probe_set
      end

    private
      def process_filter(hash)
        hash.select{}
      end
      # http://munin-monitoring.org/wiki/notes_on_datasource_names
      # Notes on field names
      # Each data source in a plugin must be identified by a field name. The following describes the name of the field:

      # The characters must be [a-zA-Z0-9_], while the first character must be [a-zA-Z_].
      # Previously we documented that there the datasource name cannot exceed 19 characters in length. This was a limit inherited by munin 1.0 from rrd. In munin 1.2 this limit has been circumvented.

      # In sed and perl these RE shold be applied to all field names to make them safe:

      # s/^[^A-Za-z_]/_/
      # s/[^A-Za-z0-9_]/_/g
      def format_field(*names)
        names.compact.join("_").gsub(/[^A-Za-z0-9_]/, '_')
      end

      def report
        @report ||= YAML.load(@data)
      end
    end

    # A little DSL that lets us set the socket and report name we'll read
    class Graph::DSL
      Category = 'App'

      def initialize(&block)
        block.arity > 1 ? block.call(self) : instance_eval(&block)
        self
      end

      def socket(host=EventMachine::Nosey::SocketServer::Host,port=EventMachine::Nosey::SocketServer::Port)
        @host, @port = host, port
        self
      end

      # Name the probset that we'll spit out for this graph
      def probe_set(probe_set)
        @probe_set = probe_set
        self
      end

      def title(title)
        @title = title
        self
      end

      def vertical_label(vertical_label)
        @vertical_label = vertical_label
        self
      end

      def data(data)
        @data = data
        self
      end

      # Category this thing will be in
      def category(category=Category)
        @category = category
        self
      end

      # Configure an instance of a client.
      def graph
        Graph.new read_data do |c|
          c.probe_set = @probe_set
          c.category = @category
          c.title = @title
          c.vertical_label = @vertical_label
        end
      end

    private
      # Let us drop a string right in here in case we need to test some stuff
      def read_data
        @data || read_socket
      end

      # Read the report YAML data from the socket
      def read_socket
        UNIXSocket.new(@host).gets("\n\n")
      end
    end
  end
end