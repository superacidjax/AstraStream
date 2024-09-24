class EventProcessor < BaseProcessor
  include ItemValidator

  private

  def item_key
    :event
  end

  def permitted_item_data(event_data)
    return event_data unless event_data.respond_to?(:permit)

    permitted = event_data.permit(:event_type, :user_id, :timestamp).to_h
    properties = validate_items(event_data[:properties], "properties")
    return if @status == :bad_request

    permitted["properties"] = properties
    permitted
  end

  def required_params
    %w[event_type user_id properties timestamp]
  end

  def process_valid_item(valid_event)
    SendEventJob.perform_later(valid_event)
  end
end
