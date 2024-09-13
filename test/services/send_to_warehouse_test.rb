require "test_helper"

class SendToWarehouseTest < ActiveSupport::TestCase
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

    @mock_analytics.stubs(:track)
    @mock_analytics.stubs(:identify)

    # this is testing the subclass to verify initialization
    SendEvent.call({
      "user_id" => "12345",
      "event_type" => "example_event",
      "properties" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00",
      "context" => { "application_id" => "0191e61e-40a0-7584-b5b0-dae90f157d95" }
    })

    SendPerson.call({
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    })
  end

  test "should raise error for missing required parameters" do
    assert_raises(ArgumentError, "Missing required parameters: user_id, timestamp") do
      SendToWarehouse.error_for_missing([ "user_id", "timestamp" ], {
        "user_id" => "",
        "timestamp" => nil
      })
    end
  end

  test "should not raise error if all required parameters are present" do
    assert_nothing_raised do
      SendToWarehouse.error_for_missing([ "user_id", "timestamp" ], {
        "user_id" => "12345",
        "timestamp" => "2010-10-25T23:48:46+00:00"
      })
    end
  end

  test "should raise error for multiple missing parameters in a batch" do
    people_data = [
      { "user_id" => "12345", "traits" => { "key" => "value" }, "context" => { "application_id" => "94948" }, "timestamp" => nil },
      { "user_id" => nil, "traits" => { "key" => "value" }, "context" => { "application_id" => "94948" }, "timestamp" => "2010-10-25T23:48:46+00:00" }
    ]

    assert_raises(ArgumentError, "Missing required parameters: timestamp") do
      SendToWarehouse.error_for_missing([ "user_id", "timestamp" ], people_data[0])
    end

    assert_raises(ArgumentError, "Missing required parameters: user_id") do
      SendToWarehouse.error_for_missing([ "user_id", "timestamp" ], people_data[1])
    end
  end
end