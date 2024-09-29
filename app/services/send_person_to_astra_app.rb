class SendPersonToAstraApp < SendToAstraApp
  def self.call(person)
    self.error_for_missing(
      [ "user_id", "context", "traits", "timestamp" ],
      person)

    person_data = {
      person: {
        user_id: person["user_id"],
        traits: person["traits"],
        timestamp: person["timestamp"],
        application_id: person["context"]["application_id"]
      }
    }

    send_request("people", person_data)
  end
end
