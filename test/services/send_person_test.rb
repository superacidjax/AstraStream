require "test_helper"

class SendPersonTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  test "should identify single person with correct data" do
    person = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    @mock_analytics.expects(:identify).with(
      user_id: person["user_id"],
      traits: person["traits"],
      context: person["context"],
      timestamp: person["timestamp"]
    )

    SendPerson.call(person)
  end

  test "should raise an error for missing user_id" do
    person = {
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing user_id

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: user_id") do
      SendPerson.call(person)
    end
  end

  test "should raise an error for missing context" do
    person = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing context

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: context") do
      SendPerson.call(person)
    end
  end

  test "should raise an error for missing traits" do
    person = {
      "user_id" => "12345",
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing traits

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: traits") do
      SendPerson.call(person)
    end
  end

  test "should raise an error for missing timestamp" do
    person = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" }
    } # Missing timestamp

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError, "Missing required parameters: timestamp") do
      SendPerson.call(person)
    end
  end
end
