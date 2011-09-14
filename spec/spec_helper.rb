require 'nosey'

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
  end
end