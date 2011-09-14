require "nosey/version"

module Nosey
  class Report
    def initialize(*probes)
      p probes
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
          @_nosey ||= Nosey::Probes.new
        end
      end

      module ClassMethods
        # TODO add a configuration block up in here...
        def configure(&block)

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
  class Probes
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

  private
    # This factory creates probes based on the methods called from
    # the instrumentation. If a probe doesn't exist, we create an instance
    # from the klass and args passed in, then set the thing up in the hash key.
    def ensure_probe(klass, key, *args)
      unless probe = probes[key]
        probes[key] = probe = klass.new(*args)
      end
      probe
    end
  end
end