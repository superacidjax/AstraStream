class SendPerson < SendToWarehouse
  def self.call(person)
    error_for_missing([ "user_id", "context", "traits", "timestamp" ], person)

    identify_person(person)
  end

  private

  def self.identify_person(data)
    analytics.identify(
      user_id: data["user_id"],
      traits: flatten_traits_with_type(data["traits"]),
      context: data["context"],
      timestamp: data["timestamp"].to_time
    )
  end

  def self.flatten_traits_with_type(traits)
    traits.each_with_object({}) do |trait, hash|
      key, value = trait.keys.first, trait.values.first
      hash[key] = { "value" => value, "type" => trait["type"] }
    end
  end
end
