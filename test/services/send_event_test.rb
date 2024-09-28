require "test_helper"

class SendEventTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  test "should track single event with correct data" do
    event = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    @mock_analytics.expects(:track).with(
      user_id: event["user_id"],
      event: event["event_type"],
      properties: event["properties"],
      context: event["context"],
      timestamp: event["timestamp"].to_time
    )

    SendEvent.call(event)
  end

  test "should raise an error for missing user_id" do
    event = {
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing user_id

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: user_id") do
      SendEvent.call(event)
    end
  end

  test "should raise an error for missing event_type" do
    event = {
      "user_id" => "12345",
      "properties" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing event_type

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: event_type") do
      SendEvent.call(event)
    end
  end

  test "should raise an error for missing properties" do
    event = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing properties

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: properties") do
      SendEvent.call(event)
    end
  end

  test "should raise an error for missing context" do
    event = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing context

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: context") do
      SendEvent.call(event)
    end
  end

  test "should raise an error for missing timestamp" do
    event = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "context" => { "application_id" => "94948" }
    } # Missing timestamp

    @mock_analytics.expects(:track).never

    assert_raises(ArgumentError, "Missing required parameters: timestamp") do
      SendEvent.call(event)
    end
  end
end
