# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_examples/transmittable.rb')

RSpec.describe Operations::SugarCRM::GenerateReport do
  include Dry::Monads[:do, :result]

  include_context 'transmittable job transmission transaction'

  let(:date) { DateTime.now.strftime('%Y-%m-%d').to_date }

  describe 'success' do
    before :each do
      @result = described_class.new.call(limit: 1, date: date)
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
                    "Transaction Created At",
                    "Transaction Status",
                    "Transaction Errors",
                    "Transmission Created At",
                    "Transmission Status",
                    "Transmission Errors",
                    "Job Created At",
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
        expect(@csv[1][2]).to eql(transaction.process_status.latest_state.to_s)
      end

      it "contains transaction errors" do
        expect(@csv[1][3]).to eql(transaction.transmittable_errors.first.message.to_s)
      end

      it "contains transmission status" do
        expect(@csv[1][5]).to eql(transmission.process_status.latest_state.to_s)
      end

      it "contains job status" do
        expect(@csv[1][8]).to eql(job.process_status.latest_state.to_s)
      end
    end
  end

  describe 'Failure' do

    context "With Incorrect Date Format" do

      before :each do
        @result = described_class.new.call({limit: 100, date: '2024/01/01'})
      end

      it "returns failure" do
        expect(@result).to be_failure
      end

      it "returns failure message" do
        expect(@result.failure).to eql("Date is not a date")
      end
    end
  end

  after :all do
    # Clean up the CSV files created during the test
    Dir.glob(Rails.root.join('crm_transmittable_report_*.csv')).each do |file|
      FileUtils.rm(file)
    end
  end
end
