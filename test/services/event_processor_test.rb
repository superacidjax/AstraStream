require "test_helper"

class EventProcessorTest < ActiveSupport::TestCase
  class TestEventProcessor < EventProcessor
    private

    def process_valid_item(valid_event)
      # Simulate the event processing logic
      valid_event[:processed] = true
    end
  end

  setup do
    @api_key = api_keys(:one)  # Mock API key
    @valid_event = {
      "event_type" => "new_user_created",
      "user_id" => "12345",
      "properties" => { "key" => "value" },
      "timestamp" => "2023-10-05T14:48:00Z"
    }
    @invalid_event_missing_timestamp = {
      "event_type" => "new_user_created",
      "user_id" => "12345",
      "properties" => { "key" => "value" }
    }
    @invalid_event_missing_event_type = {
      "user_id" => "12345",
      "properties" => { "key" => "value" },
      "timestamp" => "2023-10-05T14:48:00Z"
    }
    @invalid_event_missing_user_id = {
      "event_type" => "new_user_created",
      "properties" => { "key" => "value" },
      "timestamp" => "2023-10-05T14:48:00Z"
    }
  end

  test "should process a single valid event" do
    processor = TestEventProcessor.new(
      params: { event: @valid_event }, api_key: @api_key
    )
    processor.process

    assert_equal :created, processor.status
    assert_equal @valid_event, processor.result
    assert @valid_event[:processed], "Event should be marked as processed"
  end

  test "should return bad_request for a single event with missing timestamp" do
    processor = TestEventProcessor.new(
      params: { event: @invalid_event_missing_timestamp }, api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:error],
      "Missing required parameters: timestamp"
  end

  test "should return bad_request if event_type is missing in single event" do
    processor = TestEventProcessor.new(params: { event: @invalid_event_missing_event_type }, api_key: @api_key)
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:error], "Missing required parameters: event_type"
  end

  test "should return bad_request if user_id is missing in single event" do
    processor = TestEventProcessor.new(
      params: { event: @invalid_event_missing_user_id },
      api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:error],
      "Missing required parameters: user_id"
  end

  test "should generate context with application_id and timestamp" do
    processor = TestEventProcessor.new(
      params: { event: @valid_event },
      api_key: @api_key
    )
    processor.process

    assert_not_nil processor.result["context"]["generated_at"]
    assert_equal @api_key.application_id,
      processor.result["context"]["application_id"]
  end
end
