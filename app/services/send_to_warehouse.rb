class SendToWarehouse
  def self.analytics
    initialize_rudder
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

  # General method for processing single item
  def self.process(item, required_params:, single_method:)
    begin
      # Make sure to check for missing required params here
      error_for_missing(required_params, item)
      send(single_method, item)
      { success: true }
    rescue ArgumentError => e
      Rails.logger.error("Item was not processed: #{item.to_json}, Error: #{e.message}")
      { success: false, error: e.message }
    end
  end
end
