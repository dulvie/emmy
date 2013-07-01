worker_processes 4
timeout 15
preload_app true

before_fork do |server, worker|
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info "Disconnected from db"
  end
end

after_fork do |server, worker|
  if defined? ActiveRecord::Base
    ActiveRecord::Base.establish_connection
    Rails.logger.info "Connecting to db"
  end

end
