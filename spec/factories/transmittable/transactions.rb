# frozen_string_literal: true

FactoryBot.define do
  factory :transmittable_transaction, class: '::Transmittable::Transaction' do
    transient do
      transmission { nil }
    end

    after(:create) do |transaction, evaluator|
      create(:transactions_transmissions, transaction: transaction, transmission: evaluator.transmission) if evaluator.transmission
    end
  end
end
