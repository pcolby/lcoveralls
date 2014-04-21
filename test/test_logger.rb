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

require_relative '../lib/lcoveralls/logger.rb'

class TestLogger < Test::Unit::TestCase

  def test_trace
    string = StringIO.new
    logger = Logger.new string
    assert_respond_to(logger, 'trace')

    logger.sev_threshold = Logger::TRACE;
    logger.trace 'trace message 1'
    logger.sev_threshold = Logger::DEBUG;
    logger.trace 'debug message 2'
    logger.sev_threshold = Logger::TRACE;
    logger.trace 'trace message 3'

    string.rewind
    lines = string.readlines
    assert_equal(2, lines.count)

    assert_match(
      /^A, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+) #\d+\] *ANY -- : trace message 1$/,
      lines[0])
    assert_match(
      /^A, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+) #\d+\] *ANY -- : trace message 3$/,
      lines[1])
  end

  def test_trace?
    logger = Logger.new StringIO.new
    logger.sev_threshold = Logger::TRACE;   assert( logger.trace?)
    logger.sev_threshold = Logger::DEBUG;   assert(!logger.trace?)
    logger.sev_threshold = Logger::WARN;    assert(!logger.trace?)
    logger.sev_threshold = Logger::ERROR;   assert(!logger.trace?)
    logger.sev_threshold = Logger::FATAL;   assert(!logger.trace?)
    logger.sev_threshold = Logger::UNKNOWN; assert(!logger.trace?)
  end

end
