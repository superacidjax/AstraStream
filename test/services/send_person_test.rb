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

  test "should raise an error for invalid single person" do
    person = {
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing user_id

    @mock_analytics.expects(:identify).never

    assert_raises(ArgumentError) do
      SendPerson.call(person)
    end
  end

  test "should identify valid people and log errors for invalid people in batch" do
    person1 = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    person2 = {
      "traits" => { "key" => "another_value" },
      "context" => { "application_id" => "94949" },
      "timestamp" => "2010-10-25T23:50:46+00:00"
    } # Missing user_id

    @mock_analytics.expects(:identify).with(
      user_id: person1["user_id"],
      traits: person1["traits"],
      context: person1["context"],
      timestamp: person1["timestamp"]
    )

    logger_mock = mock()
    logger_mock.expects(:error).with("Some people were not processed: [{\"person\":{\"traits\":{\"key\":\"another_value\"},\"context\":{\"application_id\":\"94949\"},\"timestamp\":\"2010-10-25T23:50:46+00:00\"},\"error\":\"Missing required parameters: user_id\"}]")
    Rails.stubs(:logger).returns(logger_mock)

    SendPerson.call([ person1, person2 ])
  end

  test "should log multiple errors for invalid people in batch" do
    person1 = {
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    } # Missing user_id

    person2 = {
      "user_id" => "67890",
      "context" => { "application_id" => "94949" }
    } # Missing traits and timestamp

    @mock_analytics.expects(:identify).never

    logger_mock = mock()
    logger_mock.expects(:error).with("Some people were not processed: [{\"person\":{\"traits\":{\"key\":\"value\"},\"context\":{\"application_id\":\"94948\"},\"timestamp\":\"2010-10-25T23:48:46+00:00\"},\"error\":\"Missing required parameters: user_id\"},{\"person\":{\"user_id\":\"67890\",\"context\":{\"application_id\":\"94949\"}},\"error\":\"Missing required parameters: traits, timestamp\"}]")
    Rails.stubs(:logger).returns(logger_mock)

    SendPerson.call([ person1, person2 ])
  end

  test "should identify all valid people in batch without logging errors" do
    person1 = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    person2 = {
      "user_id" => "67890",
      "traits" => { "key" => "another_value" },
      "context" => { "application_id" => "94949" },
      "timestamp" => "2010-10-25T23:50:46+00:00"
    }

    @mock_analytics.expects(:identify).with(
      user_id: person1["user_id"],
      traits: person1["traits"],
      context: person1["context"],
      timestamp: person1["timestamp"]
    )

    @mock_analytics.expects(:identify).with(
      user_id: person2["user_id"],
      traits: person2["traits"],
      context: person2["context"],
      timestamp: person2["timestamp"]
    )

    Rails.logger.expects(:error).never

    SendPerson.call([ person1, person2 ])
  end
end
