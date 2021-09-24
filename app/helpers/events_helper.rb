# frozen_string_literal: true

# Namespace container Events view helpers
module EventsHelper
  def event_row(event)
    safe_join(event.data[:family_members].map { |p| p[:person][:person_name][:full_name] }, tag.br)
  end

  def js_timeago(timestamp)
    tag.span(class: 'timeago', datetime: timestamp.strftime('%Y-%m-%dT%H:%M:%S.%L%z'))
  end
end
