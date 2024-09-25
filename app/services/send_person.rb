class SendPerson < SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    people = data.is_a?(Array) ? data : [ data ]

    if people.size == 1
      self.error_for_missing([ "user_id", "context", "traits", "timestamp" ], people.first)
      self.identify_person(people.first, analytics)
    else
      valid_people = []
      invalid_people = []

      people.each do |person|
        begin
          self.error_for_missing([ "user_id", "context", "traits", "timestamp" ], person)
          valid_people << person
        rescue ArgumentError => e
          invalid_people << { person: person, error: e.message }
        end
      end

      valid_people.each { |person| self.identify_person(person, analytics) }

      if invalid_people.any?
        Rails.logger.error "Some people were not processed: #{invalid_people.to_json}"
      end
    end
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
