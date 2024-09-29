require "test_helper"

class SendDataTest < ActiveSupport::TestCase
  test "should raise error for missing required parameters" do
    assert_raises(ArgumentError, "Missing required parameters: user_id, timestamp") do
      SendData.error_for_missing([ "user_id", "timestamp" ], {
        "user_id" => "",
        "timestamp" => nil
      })
    end
  end

  test "should not raise error if all required parameters are present" do
    assert_nothing_raised do
      SendData.error_for_missing([ "user_id", "timestamp" ], {
        "user_id" => "12345",
        "timestamp" => "2010-10-25T23:48:46+00:00"
      })
    end
  end
end
