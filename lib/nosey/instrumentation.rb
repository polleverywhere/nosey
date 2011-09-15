module Nosey
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
end