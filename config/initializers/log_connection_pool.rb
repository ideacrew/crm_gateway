
# /usr/local/bundle/ruby/3.2.0/gems/mongo-2.16.0/lib/mongo/server/connection_pool.rb:386:in `block (2 levels) in check_out'

module ConnectionLoggingHack
  def format_caller(caller_obj)
    caller_obj.join("\n")
  end

  def check_out(service_id: nil)
    Rails.logger.error { "Checking out connection from pool #{service_id}, caller: #{format_caller(caller)}" }

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
