# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Families::HandleFamilyUpdate, dbclean: :after_each do
  let(:params) do
    {
      hbx_id: '',
      family_members: '',
      households: '',
      documents_needed: ''
    }
  end
  let(:update_handler) do
    Families::HandleFamilyUpdate.new.call(params)
  end
end
