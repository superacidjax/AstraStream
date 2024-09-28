require "test_helper"

class SendDataTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  test "should initialize Rudder with correct credentials" do
    Rudder::Analytics.expects(:new).with(
      write_key: Rails.application.credentials.dig(:rudder, :write_key),
      data_plane_url: Rails.application.credentials.dig(:rudder, :data_plane_url),
      on_error: instance_of(Proc)
    ).returns(@mock_analytics)

    SendData.analytics
  end

  test "should raise error for missing required parameters" do
    assert_raises(ArgumentError, "Missing required parameters: user_id, timestamp") do
      SendData.error_for_missing([ "user_id", "timestamp" ], {
        "user_id" => "",
        "timestamp" => nil
      })
    end
  end

  test "should not raise error if all required parameters are present" do
    assert_nothing_raised do
      SendData.error_for_missing([ "user_id", "timestamp" ], {
        "user_id" => "12345",
        "timestamp" => "2010-10-25T23:48:46+00:00"
      })
    end
  end

  test "should call send_person in send_to_astragoal" do
    person_data = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    SendToAstragoal.expects(:send_person).with(person_data)
    SendData.send_to_astragoal("send_person", person_data)
  end

  test "should call send_event in send_to_astragoal" do
    event_data = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    }

    SendToAstragoal.expects(:send_event).with(event_data)
    SendData.send_to_astragoal("send_event", event_data)
  end

  test "should raise error for invalid origin in send_to_astragoal" do
    invalid_data = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    assert_raises(ArgumentError, "Invalid origin: invalid_origin") do
      SendData.send_to_astragoal("invalid_origin", invalid_data)
    end
  end
end
