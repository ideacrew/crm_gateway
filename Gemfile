# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7.1'
# Use Puma as the app server
gem 'puma', '>= 5.6.4'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
gem 'aasm'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'aca_entities',  git:  'https://github.com/ideacrew/aca_entities.git', branch: 'trunk'
# Enroll branch enroll_ridp_1.0 has some activity around this
# https://github.com/ideacrew/enroll/tree/enroll_ridp_1.0/app/event_source
gem 'event_source', git: 'https://github.com/ideacrew/event_source.git', branch: 'trunk'

gem 'awesome_print'
gem 'dry-matcher',     '~> 0.8'
gem 'dry-monads',      '~> 1.3'
gem 'dry-struct',      '~> 1.4'
gem 'dry-transaction'
gem 'dry-types',       '~> 1.5'
gem 'dry-validation',  '~> 1.6'
gem 'mongoid',         '~> 7.3.3'
gem 'oauth2'
gem 'sinatra', '~> 2.2.3'
gem 'stimulus_reflex', '~> 3.4'
gem 'webpacker'

group :development, :test do
  gem 'brakeman'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'rspec-rails',      '~> 4.0'
  gem 'shoulda-matchers', '~> 3'
  gem 'vcr'
  gem 'yard'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rubocop',       require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-git',   require: false
  gem 'prettier',      require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
