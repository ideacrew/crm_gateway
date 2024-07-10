# frozen_string_literal: true

RSpec.shared_context 'a full transmittable setup with family as subject', shared_context: :metadata do
  let(:job)           { FactoryBot.create(:transmittable_job, key: :crm_update) }
  let(:transmission)  { FactoryBot.create(:transmittable_transmission, job: job) }
  let(:family)        { FactoryBot.create(:family) }
  let(:transaction)   { FactoryBot.create(:transmittable_transaction, transactable: family, transmission: transmission) }
end
