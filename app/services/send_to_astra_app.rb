class SendToAstraApp < SendData
  private

  def self.send_request(endpoint, data)
    uri = URI.parse("#{astra_base_url}/#{endpoint}")

    Rails.logger.debug { "AstraBase URL: #{astra_base_url}" }
    Rails.logger.debug { "Request Endpoint: #{endpoint}" }
    Rails.logger.debug { "Request Data: #{data.to_json}" }

    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")

    self.add_basic_auth(request)

    request.body = data.to_json
    Rails.logger.debug { "Final Request Body: #{request.body}" }

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
      Rails.logger.debug { "Response Code: #{response.code}" }
      Rails.logger.debug { "Response Body: #{response.body}" }
      response
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      Rails.logger.error { "Request Timeout Error: #{e.message}" }
      raise
    rescue StandardError => e
      Rails.logger.error { "Error during HTTP request: #{e.message}" }
      raise
    end
  end

  def self.astra_base_url
    base_url = ENV["ASTRA_BASE_URL"]
    Rails.logger.debug { "Using Astra Base URL: #{base_url}" }
    base_url
  end

  def self.add_basic_auth(request)
    username = Rails.application.credentials.dig(:astragoal, :username)
    password = Rails.application.credentials.dig(:astragoal, :password)

    if username.nil? || password.nil?
      Rails.logger.error { "Send to AstraApp Credentials are missing" }
      raise "Send to AstraApp Credentials are missing"
    end

    Rails.logger.debug { "Adding Basic Auth for user: #{username}" }
    request.basic_auth(username, password)
  end
end
