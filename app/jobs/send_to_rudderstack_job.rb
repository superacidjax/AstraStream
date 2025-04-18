class SendToRudderstackJob < ApplicationJob
  queue_as :people_events

  def perform(kind, data)
    return if ENV["RUDDERSTACK_SEND"] == "false"

    if kind == "person"
      SendPersonToRudderstack.call(data)
    elsif kind == "event"
      SendEventToRudderstack.call(data)
    end
  end
end
