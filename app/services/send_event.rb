class SendEvent < SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    events = data.is_a?(Array) ? data : [ data ]  # Handle single or multiple events

    if events.size == 1
      # For a single event, raise an error immediately if it's invalid
      self.track_event(events.first, analytics)
    else
      # For multiple events, process valid ones and log the invalid ones
      valid_events = []
      invalid_events = []

      events.each_with_index do |event, index|
        begin
          self.track_event(event, analytics)
          valid_events << event
        rescue ArgumentError => e
          invalid_events << { event: event, error: e.message }
        end
      end

      if invalid_events.any?
        Rails.logger.error("Some events were not processed: #{invalid_events.to_json}")
      end

      # Optional: You can return some summary information here if needed
      {
        processed_count: valid_events.size,
        errors: invalid_events
      }
    end
  end

  private

  def self.track_event(data, analytics)
    # Ensure all required fields are present
    self.error_for_missing(
      [ "user_id", "event_type", "properties", "context", "timestamp" ],
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
    missing_params = required_fields.select do |field|
      data[field].nil? || data[field] == "" || (field == "context" && data["context"]["application_id"].blank?)
    end

    if missing_params.any?
      raise ArgumentError, "Missing required parameters: #{missing_params.join(', ')}"
    end
  end
end
