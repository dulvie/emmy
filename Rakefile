# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'dotenv/tasks'
require File.expand_path('../config/application', __FILE__)
require 'resque/tasks'
Emmy::Application.load_tasks
task 'resque:setup' => :environment