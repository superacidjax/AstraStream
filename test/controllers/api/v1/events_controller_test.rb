require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = api_keys(:one)
    SendEvent.stubs(:call)
    @valid_event = {
      event_type: "new_user_created",
      user_id: "12345",
      properties: {
        key: "value"
      },
      timestamp: "2010-10-25T23:48:46+00:00"
    }
  end

  test "should create single event with valid API secret and generate context" do
    post api_v1_events_url,
      params: { event: @valid_event },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :created
    response_data = JSON.parse(response.body)
    assert_equal @api_key.application_id, response_data["context"]["application_id"]
  end

  test "should create multiple events with valid API secret and generate context" do
    post api_v1_events_url,
      params: { events: [ @valid_event, @valid_event ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :created
    response_data = JSON.parse(response.body)
    assert_equal "All events created successfully", response_data["message"]
  end

  test "should return bad request if event_type is missing in single event" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:event_type)

    post api_v1_events_url,
      params: { event: invalid_event },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    assert_includes @response.body, "Missing required parameters: event_type"
  end

  test "should return bad request if event_type is missing in multiple events" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:event_type)

    post api_v1_events_url,
      params: { events: [ @valid_event, invalid_event ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["details"].map { |e| e["missing_params"] }, [ "event_type" ]
  end

  test "should return bad request if timestamp is missing in single event" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:timestamp)

    post api_v1_events_url,
      params: { event: invalid_event },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    assert_includes @response.body, "Missing required parameters: timestamp"
  end

  test "should return bad request if timestamp is missing in multiple events" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:timestamp)

    post api_v1_events_url,
      params: { events: [ @valid_event, invalid_event ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["details"].map { |e| e["missing_params"] }, [ "timestamp" ]
  end

  test "should return bad request if user_id is missing in single event" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:user_id)

    post api_v1_events_url,
      params: { event: invalid_event },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    assert_includes @response.body, "Missing required parameters: user_id"
  end

  test "should return bad request if user_id is missing in multiple events" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:user_id)

    post api_v1_events_url,
      params: { events: [ @valid_event, invalid_event ] },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["details"].map { |e| e["missing_params"] }, [ "user_id" ]
  end

  test "should reject non-POST requests" do
    get api_v1_events_url
    assert_response :not_found

    put api_v1_events_url
    assert_response :not_found

    delete api_v1_events_url
    assert_response :not_found
  end

  test "should return unauthorized for invalid API secret" do
    post api_v1_events_url,
      params: { event: @valid_event },
      headers: { Authorization: "Basic #{Base64.encode64('invalid_secret:')}" }

    assert_response :unauthorized
  end
end
