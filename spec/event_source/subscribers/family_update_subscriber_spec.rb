# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscribers::FamilyUpdateSubscriber, dbclean: :after_each do
  subject do
    Subscribers::FamilyUpdateSubscriber.new
  end

  let(:payload) do
  end
end
