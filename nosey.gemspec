# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nosey/version"

Gem::Specification.new do |s|
  s.name        = "nosey"
  s.version     = Nosey::VERSION
  s.authors     = ["Brad Gessler"]
  s.email       = ["brad@bradgessler.com"]
  s.homepage    = "https://github.com/polleverywhere/nosey"
  s.summary     = %q{Instrument Ruby EventMachine applications}
  s.description = %q{Nosey is a way to instrument your Evented Ruby applications to track counts, aggregates, etc. It was built a Poll Everywhere because we need a way to peer into our Evented apps and grab some basic statistics so that we could graph on Munin. Since we needed this instrumentation available in several EM projects, we gathered the basics up into this gem.}

  s.rubyforge_project = "nosey"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "psych"

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'em-ventually'
  s.add_development_dependency 'ruby-debug19'
end