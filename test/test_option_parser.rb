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

require 'test_helper'

require_relative '../lib/lcoveralls/option_parser'

class TestOptionParser < Test::Unit::TestCase

  def setup
    @jobNumber = ENV['TRAVIS_JOB_NUMBER'] if ENV.has_key? 'TRAVIS_JOB_NUMBER'
    @jobId     = ENV['TRAVIS_JOB_ID']     if ENV.has_key? 'TRAVIS_JOB_ID'
  end

  def teardown
    if defined? @jobNumber then
      ENV['TRAVIS_JOB_NUMBER'] = @jobNumber
    else
      ENV.delete('TRAVIS_JOB_NUMBER')
    end
    if defined? @jobId then
      ENV['TRAVIS_JOB_ID'] = @jobId
    else
      ENV.delete('TRAVIS_JOB_ID')
    end
  end

  def test_parse_defaults_with_travis
    ENV['TRAVIS_JOB_NUMBER'] = 'test-job-number'
    ENV['TRAVIS_JOB_ID']     = 'test-job-id'

    parser = Lcoveralls::OptionParser.new
    options = parser.parse! []

    assert_equal($stderr.isatty,       options[:color])
    assert_equal('git',                options[:git])
    assert_equal(ENV['TRAVIS_JOB_ID'], options[:job_id])
    assert_equal(0,                    options[:retry_count])
    assert_equal(10.0,                 options[:retry_interval])
    assert_equal('travis-ci',          options[:service])
    assert_equal(Logger::INFO,         options[:severity])
  end

  def test_parse_defaults_without_travis
    ENV.delete('TRAVIS_JOB_NUMBER')
    ENV.delete('TRAVIS_JOB_ID')

    parser = Lcoveralls::OptionParser.new
    options = parser.parse! []

    assert_equal($stderr.isatty,    options[:color])
    assert_equal('git',             options[:git])
    assert_equal(0,                 options[:retry_count])
    assert_equal(10.0,              options[:retry_interval])
    assert_equal(File.basename($0), options[:service])
    assert_equal(Logger::INFO,      options[:severity])

    assert(!options.include?(:job_id))
  end

  def test_parse_dryrun
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert(!options.include?(:dryrun))

    options = parser.parse! [ '--dryrun' ]
    assert(options[:dryrun])
  end

  def test_parse_export
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert(!options.include?(:export))

    options = parser.parse! [ '--export' ]
    assert_equal($stdout, options[:export])

    options = parser.parse! [ '--export', 'stderr' ]
    assert_equal($stderr, options[:export])

    options = parser.parse! [ '--export', 'stdout' ]
    assert_equal($stdout, options[:export])

    file = Tempfile.new('lcoveralls-test')
    options = parser.parse! [ '--export', file.path ]
    assert_instance_of(File, options[:export])
    assert_equal(file.path, options[:export].path)
  end

  def test_parse_root
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert(!options.include?(:root))

    options = parser.parse! [ '-r', '.' ]
    assert_equal(File.realpath('.'), options[:root])

    options = parser.parse! [ '--root', '..' ]
    assert_equal(File.realpath('..'), options[:root])
  end

  def test_parse_service
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! [ '-s', 'short-service-option' ]
    assert_equal('short-service-option', options[:service])

    options = parser.parse! [ '--service', 'long-service-option' ]
    assert_equal('long-service-option', options[:service])
  end

  def test_parse_token
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert(!options.include?(:token))

    options = parser.parse! [ '-t', 'short-token-option' ]
    assert_equal('short-token-option', options[:token])

    options = parser.parse! [ '--token', 'long-token-option' ]
    assert_equal('long-token-option', options[:token])
  end

  def test_parse_timeout
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert(!options.include?(:timeout))

    options = parser.parse! [ '--timeout', '123.456' ]
    assert_equal(123.456, options[:timeout])
  end

  def test_parse_retry_count
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert_equal(0, options[:retry_count])

    options = parser.parse! [ '--retry-count', '123' ]
    assert_equal(123, options[:retry_count])
  end

  def test_parse_retry_interval
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert_equal(10, options[:retry_interval])

    options = parser.parse! [ '--retry-interval', '123.456' ]
    assert_equal(123.456, options[:retry_interval])
  end

  def test_parse_color
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! [ '--color', '--no-color' ]
    assert(!options[:color])

    options = parser.parse! [ '--no-color', '--color' ]
    assert(options[:color])
  end

  def test_parse_severity
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert_equal(Logger::INFO, options[:severity])

    options = parser.parse! [ '--debug' ]
    assert_equal(Logger::DEBUG, options[:severity])

    options = parser.parse! [ '--trace' ]
    assert_equal(Logger::TRACE, options[:severity])

    options = parser.parse! [ '-d' ]
    assert_equal(Logger::DEBUG, options[:severity])

    options = parser.parse! [ '--debug', '-q' ]
    assert_equal(Logger::DEBUG + 1, options[:severity])

    options = parser.parse! [ '--debug', '-q', '-q' , '-q' ]
    assert_equal(Logger::DEBUG + 3, options[:severity])

    options = parser.parse! [ '--debug', '-v' ]
    assert_equal(Logger::DEBUG - 1, options[:severity])

    options = parser.parse! [ '--debug', '-v', '-v' , '-v' ]
    assert_equal(Logger::DEBUG - 3, options[:severity])
  end

  def test_parse_git
    parser = Lcoveralls::OptionParser.new

    options = parser.parse! []
    assert_equal('git', options[:git])

    options = parser.parse! [ '--no-git' ]
    assert(!options[:git])

    options = parser.parse! [ '--git', 'git-option' ]
    assert_equal('git-option', options[:git])
  end

  def test_parse_help
    parser = Lcoveralls::OptionParser.new
    assert_raise SystemExit do parser.parse! [ '-h' ] end
    assert_raise SystemExit do parser.parse! [ '--help' ] end
  end

  def test_parse_version
    parser = Lcoveralls::OptionParser.new
    assert_raise SystemExit do parser.parse! [ '--version' ] end
  end

  def test_parse_unknown_option
    parser = Lcoveralls::OptionParser.new
    assert_raise SystemExit do parser.parse! [ '--invalid-option' ] end
  end

end
