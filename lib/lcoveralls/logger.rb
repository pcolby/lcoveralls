require 'logger'

class Logger

  TRACE = DEBUG - 1

  def trace(progname = nil, &block)
    add(TRACE, nil, progname, &block)
  end

end
