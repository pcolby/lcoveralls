require 'logger'

module Lcoveralls

  class OptionParser

    def parse!(args)
      options =  {
        :color    => $stderr.isatty,
        :service  => File.basename($0),
        :severity => Logger::INFO
      }

      if ENV.has_key? 'TRAVIS_JOB_NUMBER' then
        options[:service] = 'travis-ci'
        options[:job_id] = ENV['TRAVIS_JOB_NUMBER']
      end

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

      o.separator 'Output options:'
      o.on(      '--[no-]color', 'Colorize output') { |color| options[:color] = color }
      o.on('-d', '--debug',      'Enable debugging') { options[:severity] = Logger::DEBUG }
      o.on(      '--trace',      'Maximum output')   { options[:severity] = Logger::TRACE }
      o.on('-q', '--quiet',      'Show less output') { options[:severity] = options[:severity] + 1 }
      o.on('-v', '--verbose',    'Show more output') { options[:severity] = options[:severity] - 1 }
      o.separator ''

      o.separator 'Miscellaneous options:'
      o.on('-h', '--help',        'Print usage text, then exit')     { puts o; exit }
      o.on(      '--version',     'Print version number, then exit') { puts VERSION; exit }
      o.separator ''
      end

      begin
        parser.parse! args
        options
      rescue ::OptionParser::InvalidOption => e
        $stderr.puts parser
        $stderr.puts e
        exit!
      end
    end

  end

end
