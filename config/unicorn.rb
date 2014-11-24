root_dir = File.expand_path(File.dirname(__FILE__)+"/../").to_s
require 'resque'
require "#{root_dir}/config/redis"

PIDFILE          = ENV['UNICORN_PID'] || "#{root_dir}/tmp/pids/unicorn.pid"
WORKER_PROCESSES = ENV['UNICORN_WORKER_PROCESSES'] || "1"
PORT             = ENV['UNICORN_PORT'] || "3000"
UNICORN_LOG      = ENV['UNICORN_LOG'] || "#{root_dir}/log/unicorn.log"

worker_processes WORKER_PROCESSES.to_i
listen PORT.to_i
pid PIDFILE
stderr_path UNICORN_LOG
stdout_path UNICORN_LOG
timeout 15
preload_app true

before_fork do |server, worker|
  # Disconnect since the database connection will not carry over
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info "Disconnected from db"
  end

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end

  # If an old process is found, send a QUIT signal to that process.
  old_pidfile = "#{PIDFILE}.oldbin"
  if File.exists?(old_pidfile) && server.pid != old_pidfile
    begin
      Process.kill("QUIT", File.read(old_pidfile).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # nothing,  already killed...
    end
  end 

end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info "Connecting to db"
  end

  if defined?(Resque)
    Resque.redis = REDIS_CONNECTION
    Rails.logger.info('Connected to Redis')
  end
end
