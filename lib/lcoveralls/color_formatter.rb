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

module Lcoveralls

  # Adds some color to loggers.
  class ColorFormatter < Logger::Formatter

    # Maps log severities to color codes.
    COLOR_CODES = {
      'Warning' => '35',
      'Error'   => '31',
      'Fatal'   => '31;1',
      'Unknown' => '31;1'
    }

    # Initializes a new ColorFormatter.
    #
    # @param color [Boolean] Whether to enable color output.
    def initialize(color)
      @color = color
    end

    # Invoked by Logger objects to format a log message.
    #
    # @param severity [String] Severity of the message to format.
    # @param datetime [Time] Timestamp for the message to format.
    # @param progname [String] Name of the program that generated the message.
    # @param msg [String] The message to format.
    def call(severity, datetime, progname, msg)
      severity.capitalize!
      if severity == 'Warn' then severity = 'Warning' end

      if %w[Warning Error Fatal Unknown].include?(severity) then
        msg = "#{severity}: #{msg}"
      end

      color_code = COLOR_CODES[severity] if @color
      if color_code then
        "\x1b[#{color_code}m#{msg}\x1b[0m\n"
      else
        "#{msg}\n"
      end
    end

  end

end
