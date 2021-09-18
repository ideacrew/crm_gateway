# frozen_string_literal: true

# Namespace container Events view helpers
module EventsHelper
  def event_row(event)
    safe_join(event.data[:family_members].map { |p| p[:person][:person_name][:full_name] }, tag('br'))
  end
end
