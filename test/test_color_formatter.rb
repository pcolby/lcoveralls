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

require_relative '../lib/lcoveralls/color_formatter'

class TestColorFormatter < Test::Unit::TestCase

  def test_call_with_color
    formatter = Lcoveralls::ColorFormatter.new true
    assert_equal("message\n", formatter.call('invalid', nil, nil, 'message'))
    assert_equal("message\n", formatter.call('DEBUG',   nil, nil, 'message'))
    assert_equal("message\n", formatter.call('INFO',    nil, nil, 'message'))
    assert_equal("\e[35mWarning: message\e[0m\n",
                 formatter.call('WARNING', nil, nil, 'message'))
    assert_equal("\e[31mError: message\e[0m\n",
                 formatter.call('ERROR', nil, nil, 'message'))
    assert_equal("\e[31;1mFatal: message\e[0m\n",
                 formatter.call('FATAL', nil, nil, 'message'))
    assert_equal("\e[31;1mUnknown: message\e[0m\n",
                 formatter.call('UNKNOWN', nil, nil, 'message'))
  end

  def test_call_without_color
    formatter = Lcoveralls::ColorFormatter.new false
    assert_equal("message\n", formatter.call('invalid', nil, nil, 'message'))
    assert_equal("message\n", formatter.call('DEBUG',   nil, nil, 'message'))
    assert_equal("message\n", formatter.call('INFO',    nil, nil, 'message'))
    assert_equal("Warning: message\n",
                 formatter.call('WARNING', nil, nil, 'message'))
    assert_equal("Error: message\n",
                 formatter.call('ERROR', nil, nil, 'message'))
    assert_equal("Fatal: message\n",
                 formatter.call('FATAL', nil, nil, 'message'))
    assert_equal("Unknown: message\n",
                 formatter.call('UNKNOWN', nil, nil, 'message'))
  end

end
