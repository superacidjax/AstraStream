class SendPerson < SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    self.identify_person(data, analytics)
  end

  private

  def self.identify_person(data, analytics)
    self.error_for_missing([ "user_id", "context", "traits", "timestamp" ], data)

    analytics.identify(
      user_id: data["user_id"],
      traits: data["traits"],
      context: data["context"],
      timestamp: data["timestamp"]
    )
  end
end
