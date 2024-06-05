# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'default async_publish_updated_families namespace client specific configurations' do
  describe 'async_publish_updated_families' do
    context 'for default value' do
      it 'returns default value of false' do
        expect(
          CrmGatewayRegistry.feature_enabled?(:async_publish_updated_families)
        ).to be_falsey
      end
    end
  end
end