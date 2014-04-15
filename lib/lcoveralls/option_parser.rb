require 'logger'

module Lcoveralls

  class OptionParser

    def parse!(args)
      options =  {}
      parser = ::OptionParser.new do |o|
      o.banner = "Usage: #{o.program_name} [options] [tracefile(s)]"
      o.summary_width = 20
      o.separator ''

      o.separator 'Code / coveralls.io options:'
      o.on(      '--dryrun',      'Do not actually submit to coveralls.io' ) { options[:dryrun] = true }
      o.on('-r', '--root PATH',   'Set the path to the repo root')   { |path|  options[:root]  = path  }
      o.on('-s', '--service NAME','Set coveralls service name')      { |name|  options[:service] = name }
      o.on('-t', '--token TOKEN', 'Set coveralls repo token')        { |token| options[:token] = token }
      o.separator ''

      o.separator 'Logging options:'
      #o.on('-q', '--quiet',   'Show less output') { log.sev_threshold = log.sev_threshold + 1 }
      #o.on('-v', '--verbose', 'Show more output') { log.sev_threshold = log.sev_threshold - 1 }
      o.separator ''

      o.separator 'Miscellaneous options:'
      o.on('-h', '--help',        'Print usage text, then exit')     { puts o; exit }
      o.on(      '--version',     'Print version number, then exit') { puts VERSION; exit }
      o.separator ''
      end

      begin
      #@log = Logger.new(STDERR)
      #@log.sev_threshold = Logger::INFO
      parser.parse! args
      #@log.formatter = Lcoveralls::ColorFormatter.new # @todo Apply --color option.
      rescue ::OptionParser::InvalidOption => e
      $stderr.puts opts
      $stderr.puts e
      exit 1
      end

      options
    end

  end

end
