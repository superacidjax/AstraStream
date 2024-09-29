class SendPersonToRudderstack < SendToRudderstack
  def self.call(person)
    self.error_for_missing([ "user_id", "context", "traits", "timestamp" ], person)
    self.identify_person(person, self.initialize_rudder)
  end

  private

  def self.identify_person(data, analytics)
    analytics.identify(
      user_id: data["user_id"],
      traits: data["traits"],
      context: data["context"],
      timestamp: data["timestamp"].to_time
    )
  end
end
