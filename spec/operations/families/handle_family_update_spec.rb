require 'rails_helper'

RSpec.describe Families::HandleFamilyUpdate, :dbclean => :after_each do
  let(:params) do
    {
      :hbx_id=>"10000", :family_members=>[
        {
          :is_primary_applicant=>true,
          :person=>{
            :hbx_id=>"20413b32edbb43a78f28004602c5bf53",
            :person_name=>{:first_name=>"John", :last_name=>"Smith1"},
            :person_demographics=>{
              :ssn=>nil, :gender=>"male", :dob=>Tue, 04 Apr 1972, :is_incarcerated=>false
            },
            :person_health=>{
              :is_tobacco_user=>"unknown"
            }, :is_active=>true,
            :is_disabled=>nil,
            :addresses=>[
              {
                :kind=>"home", :address_1=>"1111 Awesome Street NE",
                :address_2=>"#111", :address_3=>"", :city=>"Washington",\
                :state=>"DC", :zip=>"01001"
              }
            ]
          }
        },
        {
          :is_primary_applicant=>false,
          :person=>{
            :hbx_id=>"a4eaae20f93a49cda972926cf075dc3c",
            :person_name=>{
              :first_name=>"John",
              :last_name=>"Smith2"
            },
            :person_demographics=>{
              :ssn=>nil, :gender=>"male", :dob=>Tue, 04 Apr 1972, :is_incarcerated=>false
            },
            :person_health=>{:is_tobacco_user=>"unknown"},
            :is_active=>true,
            :is_disabled=>nil,
            :addresses=>[
              {
                :kind=>"home", :address_1=>"1113 Awesome Street NE",
                :address_2=>"#113", :address_3=>"", :city=>"Washington",
                :state=>"DC", :zip=>"01001"
              }
            ]
          }
        }
      ],
      :households=>[
        {
          :start_date=>Wed, 01 Sep 2021,
          :is_active=>false,
          :coverage_households=>[
            {
              :is_immediate_family=>true, :coverage_household_members=>[{:is_subscriber=>true}]
            },
            {:is_immediate_family=>false, :coverage_household_members=>[]}], :hbx_enrollments=>[]
          },
          {
            :start_date=>Thu, 01 Jul 2021, :is_active=>true,
            :coverage_households=>[], :hbx_enrollments=>[]}], :documents_needed=>false
    } 

  end
  let(:update_handler) do
    Families::HandleFamilyUpdate.new.call(params)
  end
end
