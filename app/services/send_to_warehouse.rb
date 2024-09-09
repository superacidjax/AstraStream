module SendToWarehouse
  def self.call(data)
    analytics = self.initialize_rudder
    self.analytics_track(data, analytics)
  end

  private

  def self.initialize_rudder
    Rudder::Analytics.new(
      write_key: Rails.application.credentials.dig(
        :rudder, :write_key
      ),
      data_plane_url: Rails.application.credentials.dig(
        :rudder, :data_plane_url
      ),
      on_error: proc { |error_code, error_body, exception, response| }
    )
  end

  def self.analytics_track(data, analytics)
    analytics.track(
      user_id: data["user_id"],
      event: data["event_type"],
      properties: data["data"]
    )
  end
end
