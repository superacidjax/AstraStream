class SendToRudderstack < SendData
  def self.analytics
    @analytics ||= initialize_rudder
  end

  def self.initialize_rudder
    Rudder::Analytics.new(
      write_key: Rails.application.credentials.dig(:rudder, :write_key),
      data_plane_url: Rails.application.credentials.dig(:rudder, :data_plane_url),
      on_error: proc { |error_code, error_body, _exception, _response|
        Rails.logger.error "Rudder Error: #{error_code} - #{error_body}"
      }
    )
  end
end
