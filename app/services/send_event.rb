class SendEvent < SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    self.track_event(data, analytics)
  end

  private

  def self.track_event(data, analytics)
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
end
