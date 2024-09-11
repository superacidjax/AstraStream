class SendEvent < SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    self.track_event(data, analytics)
  end

  private

  def self.track_event(data, analytics)
    self.error_for_missing(
      [ "user_id", "event_type", "properties", "application_id" ],
      data
    )

    # https://www.rudderstack.com/docs/sources/event-streams/sdks/rudderstack-ruby-sdk/#track
    analytics.track(
      user_id: data["user_id"],
      event: data["event_type"],
      properties: data["data"]
    )
  end
end
