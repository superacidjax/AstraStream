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

  test "should return bad request if event_type is missing (single event)" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:event_type)

    post api_v1_events_url,
      params: { event: invalid_event },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["error"], "Missing required parameters: event_type"
  end

  test "should return bad request if timestamp is missing (single event)" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:timestamp)

    post api_v1_events_url,
      params: { event: invalid_event },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["error"], "Missing required parameters: timestamp"
  end

  test "should return bad request if user_id is missing (single event)" do
    invalid_event = @valid_event.dup
    invalid_event.delete(:user_id)

    post api_v1_events_url,
      params: { event: invalid_event },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_includes response_data["error"], "Missing required parameters: user_id"
  end
end
