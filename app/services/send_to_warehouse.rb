module SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    self.analytics_track(data, analytics)
    analytics.close
  end

  private

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

  def self.analytics_track(data, analytics)
    # https://www.rudderstack.com/docs/sources/event-streams/sdks/rudderstack-ruby-sdk/#track
    raise ArgumentError, "user_id is missing" if data["user_id"].blank?
    raise ArgumentError, "event_type is missing" if data["event_type"].blank?

    analytics.track(
      user_id: data["user_id"],
      event: data["event_type"],
      properties: data["data"]
    )
  end
end
