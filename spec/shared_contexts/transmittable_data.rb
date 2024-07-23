# frozen_string_literal: true

RSpec.shared_context 'a full transmittable setup with family as subject', shared_context: :metadata do
  let(:job)           { FactoryBot.create(:transmittable_job, key: :crm_update) }
  let(:transmission)  { FactoryBot.create(:transmittable_transmission, job: job) }
  let(:family)        { FactoryBot.create(:family) }
  let(:transaction)   { FactoryBot.create(:transmittable_transaction, transactable: family, transmission: transmission) }

  before :each do
    transaction
  end
end

RSpec.shared_context 'two full transmittable objects with one family each for the same family hbx id', shared_context: :metadata do
  let(:job1)           { FactoryBot.create(:transmittable_job, key: :crm_update) }
  let(:transmission1)  { FactoryBot.create(:transmittable_transmission, job: job1) }
  let(:family1)        { FactoryBot.create(:family) }
  let(:transaction1)   { FactoryBot.create(:transmittable_transaction, transactable: family1, transmission: transmission1) }

  let(:job2)           { FactoryBot.create(:transmittable_job, key: :crm_update) }
  let(:transmission2)  { FactoryBot.create(:transmittable_transmission, job: job2) }
  let(:family2)        do
    FactoryBot.create(
      :family,
      correlation_id: family1.correlation_id,
      family_hbx_id: family1.family_hbx_id,
      primary_person_hbx_id: family1.primary_person_hbx_id
    )
  end
  let(:transaction2)   { FactoryBot.create(:transmittable_transaction, transactable: family2, transmission: transmission2) }

  before :each do
    transaction1
    transaction2
  end
end
