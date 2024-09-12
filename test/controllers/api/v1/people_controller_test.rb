require "test_helper"

class Api::V1::PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = api_keys(:one)
    SendPerson.stubs(:call)
  end

  test "should create person with valid API secret" do
    post api_v1_people_url,
      params: {
        person: {
          user_id: "12345",
          traits: {
            key: "value"
          },
          context: {
            application_id: "484893a"
          },
          timestamp: "2010-10-25T23:48:46+00:00"
        }
      },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :created
      response_data = JSON.parse(response.body)
      assert_equal @api_key.application_id, response_data["context"]["application_id"]
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
    post api_v1_people_url,
      params: {
        person: {
          user_id: "12345",
          traits: {
            key: "value"
          },
          context: {
            application_id: "484893a"
          },
          timestamp: "2010-10-25T23:48:46+00:00"
        }
      },
      headers: { Authorization: "Basic #{Base64.encode64('invalid_secret:')}" }

      assert_response :unauthorized
  end

  test "should return bad request if timestamp is missing" do
    post api_v1_people_url,
      params: {
        person: {
          user_id: "1231231",
          traits: {
            key: "value"
          },
          context: {
            application_id: "484893a"
          }
        }
      },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :bad_request
  end


  test "should return bad request if user_id is missing" do
    post api_v1_people_url,
      params: {
        person: {
          traits: {
            key: "value"
          },
          context: {
            application_id: "484893a"
          },
          timestamp: "2010-10-25T23:48:46+00:00"
        }
      },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :bad_request
  end

  test "should return bad request if traits are missing" do
    post api_v1_people_url,
      params: {
        person: {
          user_id: "1324"
        }
      },
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :bad_request
  end
end
