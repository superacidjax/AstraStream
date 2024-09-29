class SendEventToAstraApp < SendToAstraApp
  def self.call(event)
    self.error_for_missing(
      [ "user_id", "event_type", "properties", "context", "timestamp" ],
      event
    )

    event_data = {
      event: {
        event_type: event["event_type"],
        user_id: event["user_id"],
        properties: event["properties"],
        timestamp: event["timestamp"],
        application_id: event["context"]["application_id"]
      }
    }

    send_request("events", event_data)
  end
end
