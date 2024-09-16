require "test_helper"

class BaseProcessorTest < ActiveSupport::TestCase
  class TestProcessor < BaseProcessor
    private

    def item_key
      :test_item
    end

    def required_params
      %w[attribute_one attribute_two]
    end

    def process_valid_item(item)
      # Simulate processing of a valid item
      # For test purposes, we can just return true or modify the item in some way
      item[:processed] = true
    end
  end

  setup do
    @api_key = api_keys(:one)  # Mock API key
    @valid_item = { "attribute_one" => "value1", "attribute_two" => "value2" }
    @invalid_item = { "attribute_one" => "value1" }  # Missing attribute_two
  end

  test "should process valid items" do
    processor = TestProcessor.new(
      params: { test_item: @valid_item }, api_key: @api_key
    )
    processor.process

    assert_equal :created, processor.status
    assert_equal "Item created successfully", processor.result[:message]
    assert @valid_item[:processed], "Item should be marked as processed"
  end

  test "should return error for missing parameters in single item" do
    processor = TestProcessor.new(
      params: { test_item: @invalid_item }, api_key: @api_key
    )
    processor.process

    assert_equal :bad_request, processor.status
    assert_includes processor.result[:error],
      "Missing required parameters: attribute_two"
  end
end