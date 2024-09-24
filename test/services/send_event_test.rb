require "test_helper"

class SendEventTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  test "should track single event with correct data" do
    event_data = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => [
        { "subscription_type" => "basic", "type" => "string" },
        { "subscription_value" => "200", "type" => "numeric" }
      ],
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    }

    # Expected flattened structure for properties
    @mock_analytics.expects(:track).with(
      user_id: event_data["user_id"],
      event: event_data["event_type"],
      properties: {
        "subscription_type" => { "value" => "basic", "type" => "string" },
        "subscription_value" => { "value" => "200", "type" => "numeric" }
      },
      context: event_data["context"],
      timestamp: event_data["timestamp"].to_time
    )

    SendEvent.call(event_data)
  end
end
