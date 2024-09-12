class SendEvent < SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    events = data.is_a?(Array) ? data : [data]  # Ensure we handle both single event and array of events
    events.each { |event| self.track_event(event, analytics) }
  end

  private

  def self.track_event(data, analytics)
    # Ensure all required fields are present
    self.error_for_missing(
      ["user_id", "event_type", "properties", "context", "timestamp"],
      data
    )

    analytics.track(
      user_id: data["user_id"],
      event: data["event_type"],
      properties: data["properties"],
      context: data["context"],
      timestamp: data["timestamp"]
    )
  end

  def self.error_for_missing(required_fields, data)
    required_fields.each do |field|
      if data[field].blank? || (field == "context" && data["context"]["application_id"].blank?)
        raise ArgumentError, "#{field} is missing or blank"
      end
    end
  end
end