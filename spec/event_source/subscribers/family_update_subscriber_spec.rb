require 'rails_helper'

RSpec.describe Subscribers::FamilyUpdateSubscriber, :dbclean => :after_each do

  subject do
    Subscribers::FamilyUpdateSubscriber.new
  end

  let(:payload) do
    double(
      :headers => {
      benefit_sponsorship_id: benefit_sponsorship.id.to_s,
      new_date: renewal_effective_date.strftime("%Y-%m-%d")
      },
      :correlation_id => correlation_id)
  end
end
