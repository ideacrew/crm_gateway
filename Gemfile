# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.8.4'
# Use Puma as the app server
gem 'puma', '~> 6.4.2'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
gem 'aasm'
gem 'rack', '~> 2.2.8.1'
gem 'globalid', '~> 1.2.1'

# Internal gems
gem 'aca_entities',       git:  'https://github.com/ideacrew/aca_entities.git', branch: 'trunk'
gem 'event_source',       git: 'https://github.com/ideacrew/event_source.git', branch: 'trunk'
gem 'resource_registry',  git: 'https://github.com/ideacrew/resource_registry.git', branch: 'trunk'

gem 'awesome_print'
gem 'dry-matcher',     '~> 0.8'
gem 'dry-monads',      '~> 1.3'
gem 'dry-struct',      '~> 1.4'
gem 'dry-transaction'
gem 'dry-types',       '~> 1.6.1'
gem 'dry-validation',  '~> 1.9'
gem 'dry-container',       '0.11.0'
gem 'dry-schema',          '1.11.3'
gem 'mongoid',         '~> 7.3.3'
gem 'nokogiri',        '~> 1.16.5'
gem 'oauth2'
gem 'rbtree',  '~> 0.4.5'
gem 'sinatra', '~> 2.2.3'
gem 'stimulus_reflex', '3.4.2'
gem 'webpacker'
gem 'rexml',   '>= 3.3.3'
gem 'actiontext', '~> 7.0.8.3'

group :development, :test do
  gem 'brakeman'
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'rspec-rails',      '~> 4.0'
  gem 'shoulda-matchers', '~> 3'
  gem 'vcr'
  gem 'yard', '~> 0.9.35'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rubocop',       require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-git',   require: false
  gem 'prettier',      require: false
end

group :test do
  gem 'mongoid-rspec', '~> 4.1.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
