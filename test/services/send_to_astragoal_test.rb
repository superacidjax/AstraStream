require "test_helper"
require "mocha/minitest"

class SendToAstragoalTest < ActiveSupport::TestCase
  setup do
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

    @mock_response = mock("response")
    @mock_response.stubs(:code).returns("200")
    @mock_response.stubs(:body).returns("Success")

    @mock_http = mock("Net::HTTP")
    Net::HTTP.stubs(:start).yields(@mock_http).returns(@mock_response)
    @mock_http.stubs(:request).returns(@mock_response)

    SendToAstragoal.stubs(:log_response)
  end

  test "should send person data to the correct endpoint" do
    SendToAstragoal.expects(:add_basic_auth).once
    @mock_http.expects(:request).with(instance_of(Net::HTTP::Post)).once

    SendToAstragoal.send_person(@person_data)
  end

  test "should send event data to the correct endpoint" do
    SendToAstragoal.expects(:add_basic_auth).once
    @mock_http.expects(:request).with(instance_of(Net::HTTP::Post)).once

    SendToAstragoal.send_event(@event_data)
  end
end
