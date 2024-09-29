require "test_helper"

class SendEventToAstraAppTest < ActiveSupport::TestCase
  setup do
    @event = {
      "event_type" => "newSubscription",
      "user_id" => "12345",
      "properties" => {
        "subscription_value" => "930",
        "subscription_type" => "videopass elite"
      },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2023-10-25T23:48:46+00:00"
    }

    @expected_body = {
      event: {
        event_type: @event["event_type"],
        user_id: @event["user_id"],
        properties: @event["properties"],
        timestamp: @event["timestamp"],
        application_id: @event["context"]["application_id"]
      }
    }

    @mock_response = mock("response")
    @mock_response.stubs(:body).returns("Response body")
    SendToAstraApp.stubs(:send_request).returns(@mock_response)
  end

  test "should send correct request to AstraApp for event" do
    SendToAstraApp.expects(:send_request).with("events", @expected_body).returns(@mock_response)

    SendEventToAstraApp.call(@event)
  end

  test "should raise an error for missing user_id" do
    event = @event.except("user_id")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: user_id") do
      SendEventToAstraApp.call(event)
    end
  end

  test "should raise an error for missing event_type" do
    event = @event.except("event_type")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: event_type") do
      SendEventToAstraApp.call(event)
    end
  end

  test "should raise an error for missing properties" do
    event = @event.except("properties")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: properties") do
      SendEventToAstraApp.call(event)
    end
  end

  test "should raise an error for missing context" do
    event = @event.except("context")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: context") do
      SendEventToAstraApp.call(event)
    end
  end

  test "should raise an error for missing timestamp" do
    event = @event.except("timestamp")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: timestamp") do
      SendEventToAstraApp.call(event)
    end
  end
end
