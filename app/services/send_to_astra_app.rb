class SendToAstraApp < SendData
  private

  def self.send_request(endpoint, data)
    uri = URI.parse("#{astra_base_url}/#{endpoint}")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    self.add_basic_auth(request)

    request.body = data.to_json
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end
  end

  def self.astra_base_url
    ENV["ASTRA_BASE_URL"]
  end

  def self.add_basic_auth(request)
    username = Rails.application.credentials.dig(:astragoal, :username)
    password = Rails.application.credentials.dig(:astragoal, :password)

    raise "Send to AstraApp Credentials are missing" if username.nil? || password.nil?

    request.basic_auth(username, password)
  end
end
