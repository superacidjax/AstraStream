require "test_helper"

class SendEventJobTest < ActiveJob::TestCase
  setup do
    @event = {
      "event_type" => "user_sign_up",
      "user_id" => "12345",
      "properties" => { "source" => "web" },
      "timestamp" => "2023-10-05T14:48:00Z"
    }
    @api_key = api_keys(:one)  # Mock API key
    @context = {
      "application_id" => @api_key.application_id,
      "generated_at" => Time.current.iso8601
    }
    @event["context"] = @context
  end

  test "should enqueue job with test adapter" do
    assert_enqueued_with(job: SendEventJob, args: [ @event ]) do
      SendEventJob.perform_later(@event)
    end
  end

  test "should perform job and call SendEvent" do
    SendEvent.expects(:call).with(@event)

    SendToAstragoal.stubs(:send_event).returns(true)

    perform_enqueued_jobs do
      SendEventJob.perform_later(@event)
    end
  end
end
