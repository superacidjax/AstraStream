require "test_helper"

class SendPersonToRudderstackTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)

    @person = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }
  end

  test "should identify single person with correct data" do
    @mock_analytics.expects(:identify).with(
      user_id: @person["user_id"],
      traits: @person["traits"],
      context: @person["context"],
      timestamp: @person["timestamp"]
    )

    SendPersonToRudderstack.call(@person)
  end

  test "should raise an error for missing user_id" do
    person = @person.except("user_id")

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: user_id") do
      SendPersonToRudderstack.call(person)
    end
  end

  test "should raise an error for missing context" do
    person = @person.except("context")

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: context") do
      SendPersonToRudderstack.call(person)
    end
  end

  test "should raise an error for missing traits" do
    person = @person.except("traits")

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: traits") do
      SendPersonToRudderstack.call(person)
    end
  end

  test "should raise an error for missing timestamp" do
    person = @person.except("timestamp")

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: timestamp") do
      SendPersonToRudderstack.call(person)
    end
  end
end
