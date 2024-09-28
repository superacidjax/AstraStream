require "test_helper"

class SendEventTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)

    @event = {
      "event_type" => "user_sign_up",
      "user_id" => "12345",
      "properties" => { "source" => "web" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    SendToAstragoal.stubs(:send_event).returns(true)
  end

  test "should track single event with correct data" do
    @mock_analytics.expects(:track).with(
      user_id: @event["user_id"],
      event: @event["event_type"],
      properties: @event["properties"],
      context: @event["context"],
      timestamp: @event["timestamp"]
    )

    SendEvent.call(@event)
  end

  test "should raise an error for missing user_id" do
    event = @event.except("user_id")

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: user_id") do
      SendEvent.call(event)
    end
  end

  test "should raise an error for missing event_type" do
    event = @event.except("event_type")

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: event_type") do
      SendEvent.call(event)
    end
  end

  test "should raise an error for missing properties" do
    event = @event.except("properties")

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: properties") do
      SendEvent.call(event)
    end
  end

  test "should raise an error for missing timestamp" do
    event = @event.except("timestamp")

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: timestamp") do
      SendEvent.call(event)
    end
  end
end
