# frozen_string_literal: true

module FormatHelper

  def payload_to_account_params(primary_person)
    {
      hbxid_c: primary_person[:hbx_id],
      name: primary_person.dig(:person, :person_name, :full_name),
      email1: primary_person.dig(:person, :emails, 0, :address),
      billing_address_street: primary_person.dig(:person, :addresses, 0, :address_1),
      billing_address_street_2: primary_person.dig(:person, :addresses, 0, :address_2),
      billing_address_street_3: primary_person.dig(:person, :addresses, 0, :address_3),
      billing_address_street_4: primary_person.dig(:person, :addresses, 0, :address_4),
      billing_address_city: primary_person.dig(:person, :addresses, 0, :city),
      billing_address_postalcode: primary_person.dig(:person, :addresses, 0, :zip),
      billing_address_state: primary_person.dig(:person, :addresses, 0, :state),
      phone_office: mobile_phone_finder(primary_person.dig(:person, :phones)),
      rawssn_c: decrypt_ssn(primary_person[:person][:person_demographics][:encrypted_ssn]),
      raw_ssn_c: decrypt_ssn(primary_person[:person][:person_demographics][:encrypted_ssn]),
      dob_c: convert_dob_to_string(primary_person.dig(:person, :person_demographics, :dob)),
      enroll_account_link_c: primary_person[:person][:external_person_link]
    }
  end

  def mobile_phone_finder(payload)
    phone_number = payload.compact.detect { |number| number[:kind] == 'mobile' } ||
                   payload.compact.detect { |number| number[:kind] == 'home' } ||
                   payload.first
    phone_formatter phone_number
    end

    def phone_formatter(phone)
      return nil unless phone

      if phone[:area_code] && phone[:number]
        "(#{phone[:area_code]}) #{phone[:number].first(3)}-#{phone[:number][3..-1]}"
      elsif phone[:full_number].length == 10
        "(#{phone[:full_number].first(3)}) #{phone[:full_number][3..5]}-#{phone[:full_number][6..-1]}"
      else
        phone[:full_number]
      end
    end

end