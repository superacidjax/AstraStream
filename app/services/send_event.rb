class SendEvent < SendData
  def self.call(data)
    self.error_for_missing(
      [ "user_id", "event_type", "properties", "context", "timestamp" ],
      data
    )
    analytics = self.initialize_rudder
    self.track_event(data, analytics)
    self.send_to_astragoal("send_event", data)
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
