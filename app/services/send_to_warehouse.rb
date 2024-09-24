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

  # General method for processing single or batch data
  def self.process(data, required_params:, single_method:)
    items = data.is_a?(Array) ? data : [data]

    valid_items = []
    invalid_items = []

    items.each do |item|
      begin
        # Make sure to check for missing required params here
        error_for_missing(required_params, item)
        send(single_method, item)
        valid_items << item
      rescue ArgumentError => e
        invalid_items << { item: item, error: e.message }
      end
    end

    if invalid_items.any?
      Rails.logger.error("Some items were not processed: #{invalid_items.to_json}")
    end

    { processed_count: valid_items.size, errors: invalid_items }
  end
end
