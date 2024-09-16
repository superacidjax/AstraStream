require "test_helper"

class PersonProcessorTest < ActiveSupport::TestCase
  class TestPersonProcessor < PersonProcessor
    private

    def process_valid_item(valid_person)
      # Simulate the event processing logic
      valid_person[:processed] = true
    end
  end

  setup do
    @api_key = api_keys(:one)
    @valid_person = {
      "user_id" => "12345",
      "traits" => { "key" => "value" },
      "timestamp" => "2023-10-05T14:48:00Z"
    }
    @invalid_person_missing_user_id = {
      "traits" => { "key" => "value" },
      "timestamp" => "2023-10-05T14:48:00Z"
    }
    @invalid_person_missing_timestamp = {
      "user_id" => "12345",
      "traits" => { "key" => "value" }
    }
  end

  test "should process a single valid person" do
    processor = TestPersonProcessor.new(
      params: { person: @valid_person },
      api_key: @api_key
    )
    processor.process

    assert_equal :created, processor.status
    assert_equal @valid_person, processor.result
    assert @valid_person[:processed], "Person should be marked as processed"
  end

  test "should return bad_request for a single person with missing user_id" do
    processor = TestPersonProcessor.new(
      params: { person: @invalid_person_missing_user_id },
      api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:error], "Missing required parameters: user_id"
  end

  test "should return bad_request if timestamp is missing in single person" do
    processor = TestPersonProcessor.new(
      params: { person: @invalid_person_missing_timestamp },
      api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:error], "Missing required parameters: timestamp"
  end

  test "should generate context with application_id and timestamp" do
    processor = TestPersonProcessor.new(
      params: { person: @valid_person },
      api_key: @api_key
    )
    processor.process

    assert_not_nil processor.result["context"]["generated_at"], "generated_at should be present"
    assert_equal @api_key.application_id, processor.result["context"]["application_id"]
  end
end
