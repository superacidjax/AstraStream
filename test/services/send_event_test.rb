require "test_helper"

class SendEventTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  test "should track event with correct data" do
    event_data = {
      "user_id" => "12345",
      "application_id" => "59553",
      "event_type" => "example_event",
      "properties" => {
        "key" => "value"
      }
    }

    @mock_analytics.expects(:track).with(
      user_id: event_data["user_id"],
      event: event_data["event_type"],
      properties: event_data["data"]
    )

    SendEvent.call(event_data)
  end

  test "should raise an error if user_id is missing" do
    event_data = {
      "event_type" => "example_event",
      "data" => { "key" => "value" }
    }

    assert_raises(ArgumentError) do
      SendEvent.call(event_data)
    end
  end

  test "should raise an error if event_type is missing" do
    event_data = {
      "user_id" => "12345",
      "application_id" => "59553",
      "properties" => { "key" => "value" }
    }

    assert_raises(ArgumentError) do
      SendEvent.call(event_data)
    end
  end
end
