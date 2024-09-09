require "test_helper"

class SendToWarehouseTest < ActiveSupport::TestCase
  setup do
    # Stub the Rudder::Analytics initialization and methods using Mocha
    @mock_analytics = mock('analytics')
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  test "should initialize Rudder with correct credentials" do
    Rudder::Analytics.expects(:new).with(
      write_key: Rails.application.credentials.dig(:rudder, :write_key),
      data_plane_url: Rails.application.credentials.dig(:rudder, :data_plane_url),
      on_error: instance_of(Proc)
    ).returns(@mock_analytics)

    @mock_analytics.stubs(:track)
    @mock_analytics.stubs(:close)

    SendToWarehouse.call({
      "user_id" => "12345",
      "event_type" => "example_event",
      "data" => { "key" => "value" }
    })
  end

  test "should track event with correct data" do
    event_data = {
      "user_id" => "12345",
      "event_type" => "example_event",
      "data" => { "key" => "value" }
    }

    # Expect the track method to be called with the correct arguments
    @mock_analytics.expects(:track).with(
      user_id: event_data["user_id"],
      event: event_data["event_type"],
      properties: event_data["data"]
    )

    # Expect close method to be called after the track
    @mock_analytics.expects(:close)

    # Call the service
    SendToWarehouse.call(event_data)
  end

  test "should raise an error if user_id is missing" do
    event_data = {
      "event_type" => "example_event",
      "data" => { "key" => "value" }
    }

    assert_raises(ArgumentError) do
      SendToWarehouse.call(event_data)
    end
  end

  test "should raise an error if event_type is missing" do
    event_data = {
      "user_id" => "12345",
      "data" => { "key" => "value" }
    }

    assert_raises(ArgumentError) do
      SendToWarehouse.call(event_data)
    end
  end
end
