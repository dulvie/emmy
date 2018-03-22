source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.10'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

gem 'resque', '~> 1.25'

gem 'devise', '~> 4.4'
gem 'responders', '~> 2.0' # required by devise
gem 'simple_form', git: 'https://github.com/plataformatec/simple_form.git'
gem 'bootstrap-sass', '~> 3.2'

# Adds backward compatibility.
gem 'protected_attributes', '~> 1.0.5'

gem 'wicked_pdf'
gem 'foreman'
gem 'dotenv'
gem 'cancan'
gem 'modernizr-rails'
gem 'state_machines-activerecord'
gem 'draper', '~> 2.0'
gem 'haml', '~> 4.0'
gem 'angularjs-rails'
gem 'active_model_serializers'
gem 'gon'
gem 'angular-ui-bootstrap-rails'
gem 'country_select'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'paperclip', '~> 5.2'
gem 'exception_notification', '~> 4.0'
gem 'puma', '~> 3.10'

# Ensure rack-protection is up to date.
gem 'rack-protection', '~> 1.5.5'

# bump due to cve CVE-2018-3741 (CVE-2018-8048 loofah)
gem 'rails-html-sanitizer', '~> 1.0.4'

group :test, :development do
  gem 'byebug'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'guard'
  gem 'guard-zeus'
  gem 'i18n-tasks'
  gem 'mailcatcher'
end

group :test do
  gem 'minitest'
  gem 'cucumber-rails', '~> 1.4', require: false
  gem 'database_cleaner'
  gem 'capybara-webkit', '~> 1.15'
  gem 'resque_unit'
  gem 'simplecov', '~> 0.7.1'
  gem 'rubocop', '~> 0.54', require: false
end
