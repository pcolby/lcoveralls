require 'logger'

class Logger

  def trace(progname = nil, &block)
    add(-1, nil, progname, &block)
  end

end
