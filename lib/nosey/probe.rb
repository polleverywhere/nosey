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

    # Calulcates a min, max, and avg for a given number of samples
    class Sampler < Base
      attr_reader :min, :max, :sum, :count

      def initialize(*args)
        reset
        super(*args)
      end

      def sample(value)
        @min = @max = value unless @min and @max

        @min = value if value < @min
        @max = value if value > @max
        @sum   += value
        @count += 1

        to_hash
      end

      def avg
        sum / count if count > 0 and sum
      end

      def to_hash
        {
          'max' => max,
          'min' => min,
          'sum' => sum,
          'avg' => avg,
          'count' => count
        }
      end

      def value
        to_hash
      end

      def reset
        @min = @max = nil
        @sum = @count = 0
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
    def increment(key,by=1)
      ensure_probe(Probe::Counter, key).increment(by)
    end

    # Decrement a counter probe
    def decrement(key,by=1)
      ensure_probe(Probe::Counter, key).decrement(by)
    end

    # Sample a number and get a sum/avg/count/min/max
    def sample(key,val)
      ensure_probe(Probe::Sampler, key).sample(val)
    end

    # Touch a timestamp probe
    def touch(key)
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