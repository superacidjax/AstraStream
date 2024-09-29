class SendEventToRudderstack < SendToRudderstack
  def self.call(data)
    self.error_for_missing(
      [ "user_id", "event_type", "properties", "context", "timestamp" ],
      data
    )
    self.track_event(data, self.initialize_rudder)
  end

  private

  def self.track_event(data, analytics)
    analytics.track(
      user_id: data["user_id"],
      event: data["event_type"],
      properties: data["properties"],
      context: data["context"],
      timestamp: data["timestamp"].to_time
    )
  end
end
