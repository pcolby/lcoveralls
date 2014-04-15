require 'logger'

module Lcoveralls

  class ColorFormatter < Logger::Formatter

    COLOR_CODES = {
      'Warning' => '35',
      'Error'   => '31',
      'Fatal'   => '31;1',
      'Unknown' => '31;1'
    }

    def initialize(color)
      @color = color
    end

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
