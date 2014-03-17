require 'psych'

module Nosey
  class Report
    def initialize
      yield self if block_given?
      self
    end

    # Make sure we end up with a flat array of probe_sets
    def probe_sets=(probe_sets)
      @probe_sets = Array(probe_sets).flatten
    end

    # Grab some probe_sets or an array
    def probe_sets
      @probe_sets ||= Array.new
    end

    # Hash representation of all the probe_sets. This gives is an intermediate
    # format that we can parse from other systems or code that needs reporting
    # data for formatting, or whatever.
    def to_hash
      # Drop the probes into the report
      probe_sets.inject({}) { |report, set|
        report[set.name.to_s] = set.probes.inject({}) { |memo, (_, probe)|
          # round the values to 2 decimal places
          memo[probe.name] = (probe.value.to_f * 100).round().to_f/100
          memo
        }
        report
      }
    end

    # Reset all the counters in each probe.
    def reset
      probe_sets.each(&:reset)
    end

    # String representation of all the probe_sets that's suitable for
    # flushing out over a socket.
    def to_s
      Psych.dump to_hash
    end
  end
end