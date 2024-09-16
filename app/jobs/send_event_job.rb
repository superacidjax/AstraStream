class SendEventJob < ApplicationJob
  queue_as :default

  def perform(event)
    SendEvent.call(event)
  end
end
