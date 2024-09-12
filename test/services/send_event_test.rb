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
      "properties" => {
        "key" => "value"
      },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => {
        "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95"
      }
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
      "properties" => {
        "key" => "value"
      },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => {
        "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95"
      }
    }

    event_data_2 = {
      "user_id" => "67890",
      "event_type" => "another_event",
      "properties" => {
        "key" => "another_value"
      },
      "timestamp" => "2011-11-25T12:34:56+00:00",
      "context" => {
        "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95"
      }
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

    SendEvent.call([event_data_1, event_data_2])
  end

  test "should raise an error if user_id is missing" do
    event_data = {
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => {
        "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95"
      }
    }

    assert_raises(ArgumentError) do
      SendEvent.call(event_data)
    end
  end

  test "should raise an error if application_id is missing" do
    event_data = {
      "user_id" => "122411",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => {}
    }

    assert_raises(ArgumentError) do
      SendEvent.call(event_data)
    end
  end

  test "should raise an error if timestamp is missing" do
    event_data = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "context" => {
        "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95"
      },
      "timestamp" => ""
    }

    assert_raises(ArgumentError) do
      SendEvent.call(event_data)
    end
  end

  test "should raise an error if event_type is missing" do
    event_data = {
      "user_id" => "12345",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => {
        "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95"
      }
    }

    assert_raises(ArgumentError) do
      SendEvent.call(event_data)
    end
  end
end