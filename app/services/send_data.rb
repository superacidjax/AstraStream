class SendData
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

  def self.error_for_missing(required_parameters_array, data)
    missing_params = required_parameters_array.select do |param|
      data[param].nil? || data[param] == "" || (data[param].is_a?(Hash) && data[param].empty?)
    end

    raise ArgumentError, "Missing required parameters: #{missing_params.join(', ')}" if missing_params.any?
  end

  def self.send_to_astragoal(origin, data)
    actions = {
      "send_person" => :send_person,
      "send_event" => :send_event
    }

    raise ArgumentError, "Invalid origin: #{origin}" unless actions.key?(origin)

    SendToAstragoal.send(actions[origin], data)
  end
end
