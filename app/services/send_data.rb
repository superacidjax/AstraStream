class SendData
  def self.error_for_missing(required_parameters_array, data)
    missing_params = required_parameters_array.select do |param|
      data[param].nil? || data[param] == "" || (data[param].is_a?(Hash) && data[param].empty?)
    end
    raise ArgumentError, "Missing required parameters: #{missing_params.join(', ')}" if missing_params.any?
  end
end
