require "test_helper"

class SendPersonToAstraAppTest < ActiveSupport::TestCase
  setup do
    @person = {
      "user_id" => "12345",
      "traits" => {
        "firstName" => "John",
        "lastName" => "Doe",
        "email" => "john@example.com",
        "currentBmi" => "21"
      },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    @expected_body = {
      person: {
        user_id: @person["user_id"],
        traits: @person["traits"],
        timestamp: @person["timestamp"],
        application_id: @person["context"]["application_id"]
      }
    }

    @mock_response = mock("response")
    @mock_response.stubs(:body).returns("Response body")
    SendToAstraApp.stubs(:send_request).returns(@mock_response)
  end

  test "should send correct request to AstraApp" do
    SendToAstraApp.expects(:send_request).with("people", @expected_body).returns(@mock_response)

    SendPersonToAstraApp.call(@person)
  end

  test "should raise an error for missing user_id" do
    person = @person.except("user_id")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: user_id") do
      SendPersonToAstraApp.call(person)
    end
  end

  test "should raise an error for missing context" do
    person = @person.except("context")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: context") do
      SendPersonToAstraApp.call(person)
    end
  end

  test "should raise an error for missing traits" do
    person = @person.except("traits")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: traits") do
      SendPersonToAstraApp.call(person)
    end
  end

  test "should raise an error for missing timestamp" do
    person = @person.except("timestamp")

    SendToAstraApp.expects(:send_request).never

    assert_raises(ArgumentError, "Missing required parameters: timestamp") do
      SendPersonToAstraApp.call(person)
    end
  end
end
