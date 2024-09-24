require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = api_keys(:one)
    SendEvent.stubs(:call)
    @valid_event = {
      event_type: "new_user_created",
      user_id: "12345",
      properties: [
        { "subscription_type" => "basic", "type" => "string" },
        { "subscription_value" => "200", "type" => "numeric" }
      ],
      timestamp: "2010-10-25T23:48:46+00:00"
    }
  end

  test "should create event with valid API secret" do
    post api_v1_events_url,
      params: { event: @valid_event },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :created
    response_data = JSON.parse(response.body)
    assert_equal @api_key.application_id, response_data["context"]["application_id"]
    assert_equal "12345", response_data["user_id"]
    assert_equal "2010-10-25T23:48:46+00:00", response_data["timestamp"]
  end

  test "should return bad request if event_type is missing (single event)" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:event_type)

    post api_v1_events_url,
      params: { event: invalid_event },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["errors"], "Missing required parameters: event_type"
  end

  test "should return bad request if timestamp is missing (single event)" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:timestamp)

    post api_v1_events_url,
      params: { event: invalid_event },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["errors"], "Missing required parameters: timestamp"
  end

  test "should return bad request if user_id is missing (single event)" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:user_id)

    post api_v1_events_url,
      params: { event: invalid_event },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["errors"], "Missing required parameters: user_id"
  end

  test "should return bad request if property type is missing" do
    invalid_event = @valid_event.dup
    invalid_event[:properties] = [
      { "subscription_type" => "basic" }  # Missing "type" key
    ]

    post api_v1_events_url,
      params: { event: invalid_event },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["errors"], "Each property must include a valid type."
  end

  test "should return bad request if property key-value pair is missing" do
    invalid_event = @valid_event.dup
    invalid_event[:properties] = [
      { "type" => "string" }  # Missing key-value pair
    ]

    post api_v1_events_url,
      params: { event: invalid_event },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["errors"], "Each property must include a key-value pair in addition to 'type'."
  end
end
