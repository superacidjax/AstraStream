require "test_helper"

class SendPersonTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  teardown do
    SendToWarehouse.instance_variable_set(:@analytics, nil)
  end

  test "should identify single person with correct data" do
    person = {
      "user_id" => "12345",
      "traits" => [ { "firstName" => "John", "type" => "string" } ],
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    @mock_analytics.expects(:identify).with(
      user_id: person["user_id"],
      traits: {
        "firstName" => { "value" => "John", "type" => "string" }
      },
      context: person["context"],
      timestamp: person["timestamp"].to_time
    )

    SendPerson.call(person)
  end

  test "should raise an error for invalid single person" do
    person = {
      "traits" => [ { "firstName" => "John", "type" => "string" } ],
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing user_id

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError) do
      SendPerson.call(person)
    end
  end
end
