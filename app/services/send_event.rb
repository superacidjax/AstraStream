class SendEvent < SendToWarehouse
  def self.call(data)
    process(
      data,
      required_params: [ "user_id", "event_type", "properties", "context", "timestamp" ],
      single_method: :track_event
    )
  end

  private

  def self.track_event(data)
    error_for_missing([ "user_id", "event_type", "properties", "context", "timestamp" ], data)

    analytics.track(
      user_id: data["user_id"],
      event: data["event_type"],
      properties: convert_properties_to_hash(data["properties"]),
      context: data["context"],
      timestamp: data["timestamp"].to_time
    )
  end

  def self.convert_properties_to_hash(properties)
    properties.each_with_object({}) do |property, hash|
      key = property.keys.first
      value = { "value" => property[key], "type" => property["type"] }
      hash[key] = value
    end
  end
end
