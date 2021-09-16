module EventsHelper
    def event_row(event)
        event.data[:family_members].map { |p| p[:person][:person_name][:full_name] }.join("<br>").html_safe
    end

    def show(event)
        ap event
    end
end
