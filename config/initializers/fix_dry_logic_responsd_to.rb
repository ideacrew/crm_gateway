require "dry/core/constants"

require "bigdecimal"
require "bigdecimal/util"
require "date"
require "dry/logic/version"

warn("You may need not this file: if dry-logic gem is upgraded to 1.5.") if Gem::Version.new(Dry::Logic::VERSION) >= Gem::Version.new('1.5')
module Dry
  module Logic
    module Predicates
      include Dry::Core::Constants

      module Methods
        # This overrides Object#respond_to? so we need to make it compatible
        def respond_to?(method, input = Undefined)
          return super if input.equal?(Undefined)

          input.respond_to?(method)
        end
      end
    end
  end
end
