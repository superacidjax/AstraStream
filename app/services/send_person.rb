class SendPerson < SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    self.identify_person(data, analytics)
  end

  private

  def self.identify_person(data, analytics)
    self.error_for_missing([ "user_id", "context", "traits" ], data)

    # https://www.rudderstack.com/docs/sources/event-streams/sdks/rudderstack-ruby-sdk/#identify
    analytics.identify(
      user_id: data["user_id"],
      traits: data["traits"],
      context: data["context"]
    )
  end
end
