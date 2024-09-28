require "test_helper"

class SendPersonJobTest < ActiveJob::TestCase
  setup do
    @person = {
      "user_id" => "12345",
      "traits" => { "email" => "test@example.com" },
      "timestamp" => "2023-10-05T14:48:00Z"
    }
    @api_key = api_keys(:one)
    @context = {
      "application_id" => @api_key.application_id,
      "generated_at" => Time.current.iso8601
    }
    @person["context"] = @context
  end

  test "should enqueue job with GoodJob adapter" do
    assert_difference -> { GoodJob::Execution.count }, 1 do
      SendPersonJob.perform_later(@person)
    end
  end

  test "should perform job and call SendPerson" do
    SendPerson.expects(:call).with(@person)

    SendToAstragoal.stubs(:send_person).returns(true)

    perform_enqueued_jobs do
      SendPersonJob.perform_later(@person)
    end
  end
end
