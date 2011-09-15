require "nosey/version"

module Nosey
  autoload :Munin,            'nosey/munin'
  autoload :Report,           'nosey/report'
  autoload :Probe,            'nosey/probe'
  autoload :Instrumentation,  'nosey/instrumentation'

  # Load the EM reporting socket if event machine loaded
  def self.load_event_machine_extensions
    require 'nosey/eventmachine' # if defined? EventMachine
  end
end

Nosey.load_event_machine_extensions