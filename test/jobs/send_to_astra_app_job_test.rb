require "test_helper"

class SendToAstraAppJobTest < ActiveJob::TestCase
  setup do
    @person_data = {
      "user_id" => "12345",
      "traits" => {
        "firstName" => "John",
        "lastName" => "Doe",
        "email" => "john@example.com",
        "currentBmi" => "21"
      },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2010-10-25T23:48:46+00:00"
    }

    @event_data = {
      "event_type" => "newSubscription",
      "user_id" => "12345",
      "properties" => {
        "subscription_value" => "930",
        "subscription_type" => "videopass elite"
      },
      "context" => { "application_id" => "94948" },
      "timestamp" => "2023-10-25T23:48:46+00:00"
    }
  end

  test "should call SendToPersonToAstraApp with person data" do
    SendPersonToAstraApp.expects(:call).with(@person_data)
    SendToAstraAppJob.perform_now("person", @person_data)
  end

  test "should call SendEventToAstraApp with event data" do
    SendEventToAstraApp.expects(:call).with(@event_data)
    SendToAstraAppJob.perform_now("event", @event_data)
  end

  test "should enqueue job with correct kind and data" do
    assert_enqueued_with(job: SendToAstraAppJob, args: [ "person", @person_data ]) do
      SendToAstraAppJob.perform_later("person", @person_data)
    end

    assert_enqueued_with(job: SendToAstraAppJob, args: [ "event", @event_data ]) do
      SendToAstraAppJob.perform_later("event", @event_data)
    end
  end
end
