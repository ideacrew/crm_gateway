# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'default publish_families_updated namespace client specific configurations' do
  describe 'publish_families_updated' do
    context 'for default value' do
      it 'returns default value of false' do
        expect(
          CrmGatewayRegistry.feature_enabled?(:publish_families_updated)
        ).to be_falsey
      end
    end
  end
end