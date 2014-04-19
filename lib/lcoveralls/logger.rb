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

# Adds {TRACE} severity logging to Ruby's Logger class.
class Logger

  # {TRACE} severity is one less than +::Logger::DEBUG+.
  TRACE = DEBUG - 1

  # Log a {TRACE} message.
  #
  # See +::Logger::info+ for more information.
  def trace(progname = nil, &block)
    add(TRACE, nil, progname, &block)
  end

  # Returns +true+ if the current severity level allows for the printing of
  # {TRACE} messages.
  def trace?; @level <= TRACE; end

end
