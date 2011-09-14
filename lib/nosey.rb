require "nosey/version"

module Nosey
  class Report
    attr_reader :probe_sets

    def initialize
      yield self if block_given?
      self
    end

    def probe_sets
      @probe_sets ||= Array.new
    end

    # Hash representation of all the probe_sets. This gives is an intermediate
    # format that we can parse from other systems or code that needs reporting
    # data for formatting, or whatever.
    def to_hash
      probe_sets.inject({}) do |report, set|
        report[set.name.to_s] = set.probes.inject({}) do |memo, (_, probe)|
          memo[probe.name] = probe.value
          memo
        end
        report
      end
    end

    # String representation of all the probe_sets that's suitable for 
    # flushing out over a socket.
    def to_s
      to_hash.to_yaml
    end
  end

  module Instrumentation
    # Inject nosey instrumentation into the owning class.
    def self.included(base)
      base.send :include, DSL::InstanceMethods
    end

    module DSL
      module InstanceMethods
        # Setup instrumentation that we'll use to report stats for this thing
        def nosey
          @_nosey ||= Nosey::Probe::Set.new("#{self.class.name}##{object_id}")
        end
      end
    end
  end

  module Probe
    # Base class for containing key/value pairs in nosey. This class is responsible
    # for reseting probes.
    class Base
      attr_reader :name
      attr_accessor :value

      def initialize(name=nil, value=nil)
        @name, @value = name, value
      end

      # Set the value (don't increment or whateves)
      def set(value)
        @value = value
      end

      # Reset the value to nil
      def reset
        @value = nil
      end

      # Representation of this probe
      def to_hash
        { name => value }
      end
    end

    # Count up/down values.
    class Counter < Base
      def increment(by=1)
        change by
      end

      def decrement(by=1)
        change -by
      end

    private
      def change(by)
        self.value ||= 0 # Init at 0 if the stat is nil
        self.value += by
      end
    end

    class Touch < Base
      def touch
        self.value = Time.now
      end
    end
  end

  # Contains a collection of probes that calculate velocities, counts, etc.
  class Probe::Set
    attr_reader :name

    def initialize(name)
      @name = name
      yield self if block_given?
      self
    end

    # Increment a counter probe
    def increment(key,by=1,&blk)
      ensure_probe(Probe::Counter, key).increment(by)
    end

    # Decrement a counter probe
    def decrement(key,by=1,&blk)
      ensure_probe(Probe::Counter, key).decrement(by)
    end

    # Touch a timestamp probe
    def touch(key,&blk)
      ensure_probe(Probe::Touch, key).touch
    end

    # List of all the probes that are active
    def probes
      @probes ||= Hash.new
    end

    # Get a probe and do all sorts of crazy stuff to it.
    def probe(key)
      probes[key]
    end

    # Generate a report with this ProbeSet
    def report
      Report.new do |r|
        r.probe_sets << self
      end
    end

  private
    # This factory creates probes based on the methods called from
    # the instrumentation. If a probe doesn't exist, we create an instance
    # from the klass and args passed in, then set the thing up in the hash key.
    def ensure_probe(klass, key, *args)
      probes[key] ||= klass.new(key, *args)
    end
  end

end