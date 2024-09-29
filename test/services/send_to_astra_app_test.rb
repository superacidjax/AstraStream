require "test_helper"
require "webmock/minitest"

class SendToAstraAppTest < ActiveSupport::TestCase
  setup do
    Rails.application.credentials.stubs(:dig).with(:astragoal, :username).returns("test_username")
    Rails.application.credentials.stubs(:dig).with(:astragoal, :password).returns("test_password")

    @person_data = {
      "user_id" => "12345",
      "traits" => { "firstName" => "John", "lastName" => "Doe" },
      "timestamp" => "2023-10-25T23:48:46+00:00",
      "context" => { "application_id" => "94948" }
    }

    @event_data = {
      "event_type" => "newSubscription",
      "user_id" => "12345",
      "timestamp" => "2023-10-25T23:48:46+00:00",
      "context" => { "application_id" => "94948" },
      "properties" => {
        "subscription_type" => "premium",
        "subscription_value" => "100"
      }
    }

    WebMock.disable_net_connect!(allow_localhost: true)  # Ensure no real HTTP requests are made
  end

  test "should send person data to the correct endpoint and call add_basic_auth" do
    stub_request(:post, "http://localhost:3000/api/v1/people")
      .with(
        body: {
          person: {
            user_id: "12345",
            traits: { "firstName" => "John", "lastName" => "Doe" },
            timestamp: "2023-10-25T23:48:46+00:00",
            application_id: "94948"
          }
        }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Basic #{Base64.encode64('test_username:test_password').strip}"
        }
      )
      .to_return(status: 200, body: "Success")

    SendPersonToAstraApp.call(@person_data)

    assert_requested(:post, "http://localhost:3000/api/v1/people", times: 1)
  end

  test "should send event data to the correct endpoint and call add_basic_auth" do
    stub_request(:post, "http://localhost:3000/api/v1/events")
      .with(
        body: {
          event: {
            event_type: "newSubscription",
            user_id: "12345",
            timestamp: "2023-10-25T23:48:46+00:00",
            application_id: "94948",
            properties: {
              "subscription_type" => "premium",
              "subscription_value" => "100"
            }
          }
        }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Basic #{Base64.encode64('test_username:test_password').strip}"
        }
      )
      .to_return(status: 200, body: "Success")

    SendEventToAstraApp.call(@event_data)

    assert_requested(:post, "http://localhost:3000/api/v1/events", times: 1)
  end
end
