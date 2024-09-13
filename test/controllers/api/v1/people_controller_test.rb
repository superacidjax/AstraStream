require "test_helper"

class Api::V1::PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = api_keys(:one)
    SendPerson.stubs(:call)
  end

  test "should create single person with valid API secret and generate context" do
    valid_person = {
      user_id: "12345",
      traits: { key: "value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }

    post api_v1_people_url,
      params: { person: valid_person },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :created
    response_data = JSON.parse(response.body)
    assert_equal @api_key.application_id, response_data["context"]["application_id"]
  end

  test "should create multiple people with valid API secret and generate context" do
    valid_person = {
      user_id: "12345",
      traits: { key: "value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }

    post api_v1_people_url,
      params: { people: [ valid_person, valid_person ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :created
    response_data = JSON.parse(response.body)
    assert_equal "All people created successfully", response_data["message"]
  end

  test "should return partial success and log errors for invalid people" do
    valid_person = {
      user_id: "12345",
      traits: { key: "value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }

    invalid_person = {
      traits: { key: "another_value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }  # Missing user_id

    post api_v1_people_url,
      params: { people: [ valid_person, invalid_person ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :ok
    response_data = JSON.parse(response.body)
    assert_equal "Some people were not processed due to missing parameters", response_data["message"]
    assert_includes response_data["details"].map { |e| e["error"] }, "Missing required parameters: user_id"
  end

  test "should return bad request if user_id is missing in single person" do
    invalid_person = {
      traits: { key: "value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }  # Missing user_id

    post api_v1_people_url,
      params: { person: invalid_person },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    assert_includes @response.body, "Missing required parameters: user_id"
  end

  test "should return bad request if traits are missing in single person" do
    invalid_person = {
      user_id: "12345",
      timestamp: "2010-10-25T23:48:46+00:00"
    }  # Missing traits

    post api_v1_people_url,
      params: { person: invalid_person },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    assert_includes @response.body, "Missing required parameters: traits"
  end

  test "should return bad request if timestamp is missing in single person" do
    invalid_person = {
      user_id: "12345",
      traits: { key: "value" }
    }  # Missing timestamp

    post api_v1_people_url,
      params: { person: invalid_person },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    assert_includes @response.body, "Missing required parameters: timestamp"
  end

  test "should return partial success if user_id is missing in multiple people" do
    valid_person = {
      user_id: "12345",
      traits: { key: "value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }

    invalid_person = {
      traits: { key: "another_value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }  # Missing user_id

    post api_v1_people_url,
      params: { people: [ valid_person, invalid_person ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :ok
    response_data = JSON.parse(response.body)
    assert_includes response_data["details"].map { |e| e["error"] }, "Missing required parameters: user_id"
  end

  test "should return partial success if traits are missing in multiple people" do
    valid_person = {
      user_id: "12345",
      timestamp: "2010-10-25T23:48:46+00:00"
    }

    invalid_person = {
      user_id: "67890",
      timestamp: "2010-10-25T23:48:46+00:00"
    }  # Missing traits

    post api_v1_people_url,
      params: { people: [ valid_person, invalid_person ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :ok
    response_data = JSON.parse(response.body)
    assert_includes response_data["details"].map { |e| e["error"] }, "Missing required parameters: traits"
  end

  test "should return partial success if timestamp is missing in multiple people" do
    valid_person = {
      user_id: "12345",
      traits: { key: "value" }
    }

    invalid_person = {
      user_id: "67890",
      traits: { key: "another_value" }
    }  # Missing timestamp

    post api_v1_people_url,
      params: { people: [ valid_person, invalid_person ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :ok
    response_data = JSON.parse(response.body)
    assert_includes response_data["details"].map { |e| e["error"] }, "Missing required parameters: timestamp"
  end

  test "should reject non-POST requests" do
    get api_v1_people_url
    assert_response :not_found

    put api_v1_people_url
    assert_response :not_found

    delete api_v1_people_url
    assert_response :not_found
  end

  test "should return unauthorized for invalid API secret" do
    valid_person = {
      user_id: "12345",
      traits: { key: "value" },
      timestamp: "2010-10-25T23:48:46+00:00"
    }

    post api_v1_people_url,
      params: { person: valid_person },
      headers: { Authorization: "Basic #{Base64.encode64('invalid_secret:')}" }

    assert_response :unauthorized
  end
end
