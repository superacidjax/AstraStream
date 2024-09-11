require "test_helper"

class SendPersonTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    Rudder::Analytics.stubs(:new).returns(@mock_analytics)
  end

  test "should identify person with correct data" do
    person_data = {
      "user_id" => "12345",
      "traits" => {
        "key" => "value"
      },
      "context" => {
        "application_id" => "94948"
      }
    }

    @mock_analytics.expects(:identify).with(
      user_id: person_data["user_id"],
      traits: person_data["traits"],
      context: person_data["context"]
    )

    SendPerson.call(person_data)
  end

  test "should raise an error if user_id is missing" do
    person_data = {
      "traits" => {
        "key" => "value"
      },
      "context" => {
        "application_id": "94829"
      }
    }

    assert_raises(ArgumentError) do
      SendPerson.call(person_data)
    end
  end

  test "should raise an error if traits are missing" do
    person_data = {
      "user_id" => "12345",
      "context" => {
        "application_id": "94829"
      }
    }

    assert_raises(ArgumentError) do
      SendPerson.call(person_data)
    end
  end

  test "should raise an error if context is missing" do
    person_data = {
      "user_id" => "12345",
      "traits" => {
        "key": "value"
      }
    }

    assert_raises(ArgumentError) do
      SendPerson.call(person_data)
    end

  end
end
