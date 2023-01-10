require 'resque/tasks'
task 'resque:setup' => :environment do
  Resque.before_fork = Proc.new do |job|
    ActiveRecord::Base.connection.disconnect!
  end
  Resque.after_fork = Proc.new do |job|
    ActiveRecord::Base.establish_connection
    Resque.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
    Rails.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  end
end
