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

    @valid_person = ActionController::Parameters.new(
      {
        "user_id" => "12345",
        "traits" => [
          { "bmi" => "28", "type" => "numeric" },
          { "weight" => "70.5", "type" => "numeric" }
        ],
        "timestamp" => "2023-10-05T14:48:00Z"
      }
    )

    @invalid_person_missing_user_id = ActionController::Parameters.new(
      {
        "traits" => [
          { "bmi" => "28", "type" => "numeric" }
        ],
        "timestamp" => "2023-10-05T14:48:00Z"
      }
    )

    @invalid_person_missing_timestamp = ActionController::Parameters.new(
      {
        "user_id" => "12345",
        "traits" => [
          { "bmi" => "28", "type" => "numeric" }
        ]
      }
    )

    @invalid_person_missing_trait_type = ActionController::Parameters.new(
      {
        "user_id" => "12345",
        "traits" => [
          { "bmi" => "28" }
        ],
        "timestamp" => "2023-10-05T14:48:00Z"
      }
    )

    @invalid_person_missing_key_value = ActionController::Parameters.new(
      {
        "user_id" => "12345",
        "traits" => [
          { "type" => "numeric" }
        ],
        "timestamp" => "2023-10-05T14:48:00Z"
      }
    )
  end

  test "should process a single valid person" do
    processor = TestPersonProcessor.new(
      params: { person: @valid_person },
      api_key: @api_key
    )
    processor.process

    expected_result = {
      "user_id" => "12345",
      "timestamp" => "2023-10-05T14:48:00Z",
      "traits" => [
        { "bmi" => "28", "type" => "numeric" },
        { "weight" => "70.5", "type" => "numeric" }
      ],
      "context" => {
        "application_id" => @api_key.application_id,
        "generated_at" => Time.current.iso8601
      },
      "processed" => true,
      "message" => "Item created successfully"
    }

    assert_equal :created, processor.status
    assert_equal expected_result.except("context", "processed", "message"), processor.result.except("context", "processed", "message")
    assert processor.result["processed"], "Person should be marked as processed"
    assert_equal "Item created successfully", processor.result["message"]
    assert_not_nil processor.result["context"]["generated_at"]
    assert_equal @api_key.application_id, processor.result["context"]["application_id"]
  end

  test "should return bad_request for a single person with missing user_id" do
    processor = TestPersonProcessor.new(
      params: { person: @invalid_person_missing_user_id },
      api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:errors], "Missing required parameters: user_id"
  end

  test "should return bad_request if timestamp is missing in single person" do
    processor = TestPersonProcessor.new(
      params: { person: @invalid_person_missing_timestamp },
      api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:errors], "Missing required parameters: timestamp"
  end

  test "should return bad_request if trait type is missing" do
    processor = TestPersonProcessor.new(
      params: { person: @invalid_person_missing_trait_type },
      api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:errors], "Each trait must include a valid type."
  end

  test "should return bad_request if trait key-value pair is missing" do
    processor = TestPersonProcessor.new(
      params: { person: @invalid_person_missing_key_value },
      api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:errors], "Each trait must include a key-value pair in addition to 'type'."
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
