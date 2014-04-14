require 'logger'

module Lcoveralls

  class ColorFormatter < Logger::Formatter

    COLOR_CODES = {
      'Warning' => '35',
      'Error'   => '31',
      'Fatal'   => '31;1',
      'Unknown' => '31;1'
    }

    def call(severity, datetime, progname, msg)
      severity.capitalize!
      if severity == 'Warn' then severity = 'Warning' end

      color_code = COLOR_CODES[severity]
      if color_code then
        "\x1b[#{color_code}m#{severity}: #{msg}\x1b[0m\n"
      else
        "#{severity}: #{msg}\n"
      end
    end

  end

end
