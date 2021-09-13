# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
# rubocop:disable Naming/VariableNumber
RSpec.describe People::HandlePrimaryPersonUpdate, dbclean: :after_each do
  # Get an example of this from enroll
  let(:params) do
  {
    :hbx_id=>"aa918614ae014d42bb8547a1ae5734e1",
    :person_name=>{
      :first_name=>"John", :middle_name=>nil, :last_name=>"Smith1", :name_sfx=>nil, :name_pfx=>nil, :full_name=>"John Smith1", :alternate_name=>nil
    },
    :person_demographics=>{
      :ssn=>"775481172", :no_ssn=>false,
      :gender=>"male",
      :dob=>Date.today - 20.years,
      :date_of_death=>nil, :dob_check=>nil,
      :is_incarcerated=>true, :ethnicity=>nil,
      :race=>nil, :tribal_id=>nil, :language_code=>nil
    },
    :person_health=>{
      :is_tobacco_user=>"unknown", :is_physically_disabled=>nil
    },
    :is_active=>true, :is_disabled=>false, :no_dc_address=>false,
    :no_dc_address_reason=>nil, :is_homeless=>false,
    :is_temporarily_out_of_state=>false,
    :age_off_excluded=>false,
    :is_applying_for_assistance=>nil,
    :person_relationships=>[],
    :consumer_role=>{
      :five_year_bar=>false,
      :requested_coverage_start_date=>Date.today,
      :aasm_state=>"unverified", :is_applicant=>true,
      :birth_location=>nil, :marital_status=>nil, :is_active=>true,
      :is_applying_coverage=>true, :bookmark_url=>nil, :admin_bookmark_url=>nil,
      :contact_method=>"mail", :language_preference=>"English", :is_state_resident=>true,
      :identity_validation=>"na", :identity_update_reason=>nil, :application_validation=>"na", :application_update_reason=>nil, :identity_rejected=>false, :application_rejected=>false, :documents=>[], :vlp_documents=>[], :ridp_documents=>[], :verification_type_history_elements=>[], :lawful_presence_determination=>{:vlp_verified_at=>nil, :vlp_authority=>nil, :vlp_document_id=>nil, :citizen_status=>"us_citizen", :citizenship_result=>nil, :qualified_non_citizenship_result=>nil, :aasm_state=>"verification_pending", :ssa_responses=>[], :ssa_requests=>[], :vlp_responses=>[], :vlp_requests=>[]}, :local_residency_responses=>[], :local_residency_requests=>[]}, :resident_role=>nil, :individual_market_transitions=>[], :verification_types=>[], :user=>nil, :broker_role=>nil, :addresses=>[{:kind=>"home", :address_1=>"1111 Awesome Street NE", :address_2=>"#111", :address_3=>"", :city=>"Washington", :county=>"Hampden", :state=>"DC", :zip=>"01001", :country_name=>"United States of America", :has_fixed_address=>true}, {:kind=>"home", :address_1=>"1112 Awesome Street NE", :address_2=>"#112", :address_3=>"", :city=>"Washington", :county=>"Hampden", :state=>"DC", :zip=>"01001", :country_name=>"United States of America", :has_fixed_address=>true}], :phones=>[{:kind=>"home", :country_code=>"", :area_code=>"202", :number=>"1030404", :extension=>"", :primary=>nil, :full_phone_number=>"2021030404"}], :emails=>[{:kind=>"home", :address=>"example1@example.com"}, {:kind=>"home", :address=>"example2@example.com"}], :documents=>[], :timestamp=>{:created_at=>Time.now, :modified_at=>Time.now} 
  }
  end
  let(:update_handler) do
    People::HandlePrimaryPersonUpdate.new.call(params)
  end

  it 'should handle the primary person update' do
    expect(update_handler.errors.to_h).to eq({})
  end
end
