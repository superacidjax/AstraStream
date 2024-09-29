class SendToAstraAppJob < ApplicationJob
  queue_as :people_events

  def perform(kind, data)
    if kind == "person"
      SendPersonToAstraApp.call(data)
    elsif kind == "event"
      SendEventToAstraApp.call(data)
    end
  end
end
