# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_examples/transmittable.rb')

RSpec.describe Operations::CRMTransmittableProcessor do
  include Dry::Monads[:do, :result]

  include_context 'transmittable job transmission transaction'

  describe 'success' do
    before :each do
      @result = described_class.new.call(1)
    end

    it "returns success" do
      expect(@result).to be_success
    end

    context "csv output" do

      let(:file_name) { Rails.root.join("crm_transmittable_report_#{DateTime.now.strftime('%Y_%m_%d')}.csv") }

      before do
        @csv = CSV.read(file_name)
      end

      it "contains the correct headers" do
        headers = [
                    "Primary Person Hbx Id",
                    "Transaction Status",
                    "Transaction Errors",
                    "Transmission Status",
                    "Transmission Errors",
                    "Job Status",
                    "Job Errors",
                    "Error Message",
                    "Error Backtrace"
        ]
        expect(@csv[0]).to eql(headers)
      end

      it "contains primary person hbx id" do
        expect(@csv[1][0]).to eql(family.primary_person_hbx_id)
      end

      it "contains transaction status" do
        expect(@csv[1][1]).to eql(transaction.process_status.latest_state.to_s)
      end

      it "contains transaction errors" do
        expect(@csv[1][2]).to eql(transaction.transmittable_errors.first.message.to_s)
      end

      it "contains transmission status" do
        expect(@csv[1][3]).to eql(transmission.process_status.latest_state.to_s)
      end

      it "contains job status" do
        expect(@csv[1][5]).to eql(job.process_status.latest_state.to_s)
      end
    end
  end
end
