require "log"

require "kemal"

module StackCoin
  Log = ::Log.for("stackcoin")
end

Log.setup do |c|
  backend = Log::IOBackend.new

  c.bind "*", :info, backend

  if StackCoin::DEBUG
    c.bind "stackcoin.*", :debug, backend
    StackCoin::Log.debug { "Debug logging enabled" }
  end
end

class CrystalLogHandler < Kemal::BaseLogHandler
  def initialize(@log = ::Log.for("kemal"))
  end

  def call(context : HTTP::Server::Context)
    elapsed_time = Time.measure { call_next(context) }
    elapsed_text = elapsed_text(elapsed_time)
    @log.info { "#{Time.utc}  #{context.response.status_code} #{context.request.method} #{context.request.resource} #{elapsed_text}" }
    context
  end

  def write(message : String)
    @log.info { message }
  end

  private def elapsed_text(elapsed)
    millis = elapsed.total_milliseconds
    return "#{millis.round(2)}ms" if millis >= 1

    "#{(millis * 1000).round(2)}µs"
  end
end

Kemal.config.logger = CrystalLogHandler.new
