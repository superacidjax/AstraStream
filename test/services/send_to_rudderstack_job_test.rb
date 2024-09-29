require "test_helper"

class SendToRudderstackJobTest < ActiveJob::TestCase
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

    require_relative "../../app/services/send_person_to_rudderstack"
    require_relative "../../app/services/send_event_to_rudderstack"
  end

  test "should call SendPersonToRudderstack with person data" do
    SendPersonToRudderstack.expects(:call).with(@person_data)
    SendToRudderstackJob.perform_now("person", @person_data)
  end

  test "should call SendEventToRudderstack with event data" do
    SendEventToRudderstack.expects(:call).with(@event_data)
    SendToRudderstackJob.perform_now("event", @event_data)
  end

  test "should enqueue job with correct kind and data" do
    assert_enqueued_with(job: SendToRudderstackJob, args: [ "person", @person_data ]) do
      SendToRudderstackJob.perform_later("person", @person_data)
    end

    assert_enqueued_with(job: SendToRudderstackJob, args: [ "event", @event_data ]) do
      SendToRudderstackJob.perform_later("event", @event_data)
    end
  end
end
