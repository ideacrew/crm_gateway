# frozen_string_literal: true

# The following snippet configures RSpec to include Mongoid matchers.
RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model
end
