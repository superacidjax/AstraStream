class SendPerson < SendData
  def self.call(person)
    self.error_for_missing([ "user_id", "context", "traits", "timestamp" ], person)
    analytics = self.initialize_rudder
    self.identify_person(person, analytics)
    self.send_to_astragoal("send_person", person)
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
