module Nosey
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

    class Average < Base
      def initialize(*args)
        super(*args)
        reset
      end

      def sample(value)
        @sum   += value
        @count += 1
      end

      def value
        @sum.to_f / @count.to_f if @sum and @count > 0
      end

      def reset
        @sum   = 0
        @count = 0
        @count = 0
      end
    end

    class Minimum < Base
      def sample(value)
        @value ||= value
        @value = value if value < @value
      end
    end

    class Maximum < Base
      def sample(value)
        @value ||= value
        @value = value if value > @value
      end
    end

    class Sum < Base
      def sample(value)
        @value ||= 0
        @value += value
      end
    end

    # Count up/down values.
    class Count < Base
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
    attr_accessor :name

    def initialize(name)
      @name = name
      yield self if block_given?
      self
    end

    # Increment a counter probe
    def increment(key,by=1)
      ensure_probe(Probe::Count, key).increment(by)
    end

    # Decrement a counter probe
    def decrement(key,by=1)
      ensure_probe(Probe::Count, key).decrement(by)
    end

    # Sample a number and get a sum/avg/count/min/max
    def avg(key,val)
      ensure_probe(Probe::Average, key).sample(val)
    end

    # Touch a timestamp probe
    def touch(key)
      ensure_probe(Probe::Touch, key).touch
    end

    def min(key,value)
      ensure_probe(Probe::Minimum, key).sample(value)
    end

    def max(key,value)
      ensure_probe(Probe::Maximum, key).sample(value)
    end

    def avg(key,value)
      ensure_probe(Probe::Average, key).sample(value)
    end

    def sum(key,value)
      ensure_probe(Probe::Sum, key).sample(value)
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

    # Reset the values in all the probes
    def reset
      probes.each{|_, probe| probe.reset }
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