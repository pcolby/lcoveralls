#
# Copyright 2014 Paul Colby
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'logger'
require 'optparse'

module Lcoveralls

  class OptionParser

    def parse!(args)
      options =  {
        :color    => $stderr.isatty,
        :git      => 'git',
        :service  => File.basename($0),
        :severity => Logger::INFO
      }

      if ENV.has_key? 'TRAVIS_JOB_NUMBER' then
        options[:service] = 'travis-ci'
        options[:job_id] = ENV['TRAVIS_JOB_ID']
      end

      parser = ::OptionParser.new do |o|
      o.banner = "Usage: #{o.program_name} [options] [tracefile(s)]"
      o.summary_width = 30
      o.separator ''

      o.separator 'Code / coveralls.io options:'
      o.on(      '--dryrun',      'Do not submit to coveralls.io' ) { options[:dryrun] = true }
      o.on(      '--export [PATH=stdout]', 'Export Coveralls job data') do |path|
        options[:export] = case path
        when 'stderr'; $stderr
        when 'stdout'; $stdout
        when nil ; $stdout
        else File.new(path, 'w')
        end
      end
      o.on('-r', '--root PATH',   'Set the path to the repo root') { |path|  options[:root]  = File.realpath(path) }
      o.on('-s', '--service NAME','Set coveralls service name')    { |name|  options[:service] = name }
      o.on('-t', '--token TOKEN', 'Set coveralls repo token')      { |token| options[:token] = token }
      o.separator ''

      o.separator 'Stderr output options:'
      o.on(      '--[no-]color', 'Colorize output')  { |color| options[:color] = color }
      o.on('-d', '--debug',      'Enable debugging') { options[:severity] = Logger::DEBUG }
      o.on(      '--trace',      'Maximum output')   { options[:severity] = Logger::TRACE }
      o.on('-q', '--quiet',      'Show less output') { options[:severity] = options[:severity] + 1 }
      o.on('-v', '--verbose',    'Show more output') { options[:severity] = options[:severity] - 1 }
      o.separator ''

      o.separator 'Miscellaneous options:'
      o.on(      '--[no-]git PATH', 'Path to the git program') { |path| options[:git] = path }
      o.on('-h', '--help',    'Print usage text, then exit')     { puts o; exit }
      o.on(      '--version', 'Print version number, then exit') { puts VERSION.join('.'); exit }
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
