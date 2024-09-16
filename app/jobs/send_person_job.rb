class SendPersonJob < ApplicationJob
  queue_as :default

  def perform(person)
    SendPerson.call(person)
  end
end
