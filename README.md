
              |     |
              |     |
             /       \
            ( __   __ )   Nosey - Realtime Ruby app instrumentation.
             '--'-;  ;
                  |  |
            _     |  |
       __ /` ``""-;_ |
       \ '.;------. `\
        | |    __..  |
        | \.-''   _  |
        | |  ,-'-,   |
        |  \__.-'    |
         \    '.    /
          \     \  /
           '.      |
        jgs  )     |

Nosey is a way to instrument your Evented Ruby applications to track counts, aggregates, etc. It was built a Poll Everywhere because we need a way to peer into our Evented apps and grab some basic statistics so that we could graph on Munin. Since we needed this instrumentation available in several EM projects, we gathered the basics up into this gem.

## Getting Started

Install the gem.

    gem install nosey

Instrument your Ruby app with nosey.

    require 'nosey'
    
    class PandaBear
      include Nosey::Instrumentation

      def initialize
        nosey.touch 'started_at'
      end

      def growl(volume=1)
        nosey.touch 'last-growled-at'
        nosey.increment 'growl-count'
        nosey.avg 'growl-volume-avg', volume
        nosey.min 'growl-volume-min', volume
        nosey.max 'growl-volume-max', volume
        "G#{'r' * volume}!"
      end
    end
    
    princess = PandaBear.new
    10.times {|n| princess.growl rand * 5 }
    princess.nosey.report  # Soon to be a fantastico report, prolly in YML

When you fire Ruby this up, Nosey will open up a socket and report the stats.

    $ cat /tmp/panda_bear.rb.socket
    
    panda_bear.rb:
      started_at: 2011-09-13 23:21:52.530452000 -07:00
      last_growled_at: 2011-09-13 23:21:52.530452000 -07:00
      growls: 1

Thats the plan anyway. For now this is only going to work in EM, so its super handy if you're building EM servers and want to dump out the stats.