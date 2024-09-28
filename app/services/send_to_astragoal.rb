require "net/http"
require "json"
require "uri"

class SendToAstragoal
  def self.send_person(person)
    person_data = {
      user_id: person["user_id"],
      traits: person["traits"],
      timestamp: person["timestamp"],
      application_id: person["context"]["application_id"]
    }

    send_request("people", person_data)
  end

  def self.send_event(event_data)
    event_payload = {
      event_name: event_data["event_type"],
      user_id: event_data["user_id"],
      application_id: event_data["context"]["application_id"],
      timestamp: event_data["timestamp"],
      properties: event_data["properties"]
    }

    send_request("events", event_payload)
  end

  private

  def self.send_request(endpoint, data)
    uri = URI.parse("#{astra_base_url}/#{endpoint}")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    add_basic_auth(request)

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
    request.basic_auth(username, password)
  end
end
