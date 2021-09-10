source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.3'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
gem 'aasm',                     '~> 4.8'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'aca_entities',  git:  'https://github.com/ideacrew/aca_entities.git', branch: 'trunk'
# Enroll branch enroll_ridp_1.0 has some activity around this
# https://github.com/ideacrew/enroll/tree/enroll_ridp_1.0/app/event_source
gem 'event_source', git: 'https://github.com/ideacrew/event_source.git', branch: 'trunk'

## Verify Rails 5 eliminates need for this gem with MongoDB
gem 'database_cleaner',       '~> 1.7'

gem 'dry-matcher',          '~> 0.8'
gem 'dry-monads',           '~> 1.3'
gem 'dry-struct',           '~> 1.3'
gem 'dry-transaction'
gem 'dry-types',            '~> 1.4'
gem 'dry-validation',       '~> 1.6'
gem 'mongoid',             '~> 7.2.1'
gem 'oauth2'
gem 'overcommit'

group :development, :test do
  gem 'brakeman'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'rspec-rails',            '~> 4.0'
  gem 'shoulda-matchers',       '~> 3'
  gem 'vcr'
  gem 'yard'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'rubocop-git'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
