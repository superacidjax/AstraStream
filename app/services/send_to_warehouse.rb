class SendToWarehouse
  def self.analytics
    @analytics ||= initialize_rudder
  end

  def self.initialize_rudder
    # https://www.rudderstack.com/docs/sources/event-streams/sdks/rudderstack-ruby-sdk/#sdk-initialization-options
    Rudder::Analytics.new(
      write_key: Rails.application.credentials.dig(
        :rudder, :write_key
      ),
      data_plane_url: Rails.application.credentials.dig(
        :rudder, :data_plane_url
      ),
      on_error: proc {
        |error_code, error_body, exception, response|
        Rails.logger.error "Rudder Error: #{error_code} - #{error_body}"
      }
    )
  end

  def self.error_for_missing(required_parameters_array, data)
    required_parameters_array.each do |rp|
      raise ArgumentError, "#{rp} is missing" if data[rp].blank?
    end
  end
end
