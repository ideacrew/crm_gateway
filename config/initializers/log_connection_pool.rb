# frozen_string_literal: true

# Module for logging connection pool checkouts
module ConnectionLoggingHack
  def format_caller(caller_obj)
    caller_obj.join("\n")
  end

  def check_out(service_id: nil)
    Rails.logger.error { '------------------------------------START-----------------------------------------------' }
    Rails.logger.error { "Checking out connection from pool #{service_id}, caller: #{format_caller(caller)}" }
    Rails.logger.error { '--------------------------------------END----------------------------------------------' }

    super(service_id: service_id)
  end
end

module Mongo
  class Server
    class ConnectionPool
      prepend ConnectionLoggingHack
    end
  end
end
