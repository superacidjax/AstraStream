require "test_helper"

class ApiKeyTest < ActiveSupport::TestCase
  setup do
    @api_key = api_keys(:one)  # Use fixture to set up a test instance
  end

  test "should not save api key without application_id" do
    api_key = ApiKey.new(api_secret: SecureRandom.base58(30))
    assert_not api_key.save, "Saved the api key without an application_id"
  end

  test "should save valid api key" do
    api_key = ApiKey.new(api_secret: SecureRandom.base58(30), application_id: SecureRandom.uuid)
    assert api_key.save, "Couldn't save the api key with valid attributes"
  end

  test "should not allow duplicate api_secret" do
    duplicate_api_key = @api_key.dup
    assert_not duplicate_api_key.save, "Saved the api key with duplicate api_secret"
  end

  test "should not allow duplicate application_id" do
    duplicate_application_id_key = @api_key.dup
    duplicate_application_id_key.api_secret = SecureRandom.base58(30)
    duplicate_application_id_key.application_id = @api_key.application_id
    assert_not duplicate_application_id_key.save, "Saved the api key with duplicate application_id"
  end

  test "should generate api_secret before create" do
    api_key = ApiKey.new(application_id: UUID7.generate)
    assert_difference("ApiKey.count", 1) do
      api_key.save
    end
    assert_not_nil api_key.api_secret, "Api secret was not generated before create"
  end
end
