require "test_helper"

class Api::V1::PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = api_keys(:one)
    SendPerson.stubs(:call)
    @valid_person = {
      user_id: "0191faa2-b4d7-78bc-8cdc-6a4dc176ebb4",
      traits: [
        { bmi: "28", type: "numeric" }
      ],
      timestamp: "2010-10-25T23:48:46+00:00"
    }
  end

  test "should create person with valid API secret" do
    post api_v1_people_url,
      params: { person: @valid_person },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

    assert_response :created
    response_data = JSON.parse(response.body)
    assert_equal @api_key.application_id, response_data["context"]["application_id"]
    assert_equal "0191faa2-b4d7-78bc-8cdc-6a4dc176ebb4", response_data["user_id"]
    assert_equal "2010-10-25T23:48:46+00:00", response_data["timestamp"]
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
          traits: [ {
            bmi: "28",
            type: "numeric"
          } ],
          timestamp: "2010-10-25T23:48:46+00:00"
        }
      },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64('invalid_secret:')}" }

      assert_response :unauthorized
  end

  test "should return bad request for missing trait type" do
    post api_v1_people_url,
      params: {
        person: {
          user_id: "12345",
          traits:
            [
              {
                bmi: "28"
              },
              {
                is_happy: "true",
                type: "boolean"
              }
            ],
          timestamp: "2010-10-25T23:48:46+00:00"
        }
      },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :bad_request
  end

  test "should return bad request if timestamp is missing" do
    post api_v1_people_url,
      params: {
        person: {
          user_id: "1231231",
          traits: [ {
            bmi: "28",
            type: "numeric"
          } ]
        }
      },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :bad_request
  end

  test "should return bad request if user_id is missing" do
    post api_v1_people_url,
      params: {
        person: {
          traits: [ {
            bmi: "28",
            type: "numeric"
          } ],
          timestamp: "2010-10-25T23:48:46+00:00"
        }
      },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :bad_request
  end

  test "should return bad request if traits are missing" do
    post api_v1_people_url,
      params: {
        person: {
          user_id: "1324",
          timestamp: "2010-10-25T23:48:46+00:00"
        }
      },
      as: :json,
      headers: { Authorization: "Basic #{Base64.encode64(@api_key.api_secret)}" }

      assert_response :bad_request
  end
end
