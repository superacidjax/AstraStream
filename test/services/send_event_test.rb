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
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    }

    @mock_analytics.expects(:track).with(
      user_id: event_data["user_id"],
      event: event_data["event_type"],
      properties: event_data["properties"],
      context: event_data["context"],
      timestamp: event_data["timestamp"]
    )

    SendEvent.call(event_data)
  end

  test "should track multiple events with correct data" do
    event_data_1 = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    }

    event_data_2 = {
      "user_id" => "67890",
      "event_type" => "another_event",
      "properties" => { "key" => "another_value" },
      "timestamp" => "2011-11-25T12:34:56+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    }

    @mock_analytics.expects(:track).with(
      user_id: event_data_1["user_id"],
      event: event_data_1["event_type"],
      properties: event_data_1["properties"],
      context: event_data_1["context"],
      timestamp: event_data_1["timestamp"]
    )

    @mock_analytics.expects(:track).with(
      user_id: event_data_2["user_id"],
      event: event_data_2["event_type"],
      properties: event_data_2["properties"],
      context: event_data_2["context"],
      timestamp: event_data_2["timestamp"]
    )

    result = SendEvent.call([event_data_1, event_data_2])
    assert_equal 2, result[:processed_count]
    assert_empty result[:errors]
  end

  test "should log errors for invalid events in batch" do
    event_data_1 = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    }

    event_data_2 = {
      "event_type" => "another_event", # Missing user_id
      "properties" => { "key" => "another_value" },
      "timestamp" => "2011-11-25T12:34:56+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    }

    @mock_analytics.expects(:track).with(
      user_id: event_data_1["user_id"],
      event: event_data_1["event_type"],
      properties: event_data_1["properties"],
      context: event_data_1["context"],
      timestamp: event_data_1["timestamp"]
    )

    Rails.logger.expects(:error).with(
      "Some events were not processed: [{\"event\":{\"event_type\":\"another_event\",\"properties\":{\"key\":\"another_value\"},\"timestamp\":\"2011-11-25T12:34:56+00:00\",\"context\":{\"application_id\":\"0191e61e-40a0-7584-b5b0-dae90f157d95\"}},\"error\":\"Missing required parameters: user_id\"}]"
    )

    result = SendEvent.call([event_data_1, event_data_2])
    assert_equal 1, result[:processed_count]
    assert_equal 1, result[:errors].size
  end
end