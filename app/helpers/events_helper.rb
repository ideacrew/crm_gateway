module EventsHelper
  def event_row(event)
    event.data[:family_members].map { |p| p[:person][:person_name][:full_name] }.join("<br>").html_safe
  end

  def show(event)
    ap event
  end

  def check_time(event)
    if event.latest_timestamp.present?
      event.latest_timestamp
    else
      event.latest_timestamp
      DateTime.new(0)
    end
  end
end
