require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = api_keys(:one)
    SendToWarehouse.stubs(:call)
  end

  test "should create event with valid API secret" do
    post api_v1_events_url,
      params: {
        event: {
          event_type: "new_user_created",
          user_id: "12345",
          properties: {
            key: "value"
          }
        }
      },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :created
    response_data = JSON.parse(response.body)
    assert_equal @api_key.application_id, response_data["application_id"]
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
      params: { event: { event_type: "example_event", user_id: "12345", properties: { key: "value" } } },
      headers: { Authorization: "Basic #{Base64.encode64('invalid_secret:')}" }

    assert_response :unauthorized
  end

  test "should return bad request if event_type is missing" do
    post api_v1_events_url,
      params: { event: { user_id: "12345", properties: { key: "value" } } },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
  end

  test "should return bad request if user_id is missing" do
    post api_v1_events_url,
      params: { event: { event_type: "example_event", properties: { key: "value" } } },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :bad_request
  end
end
