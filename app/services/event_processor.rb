class EventProcessor < BaseProcessor
  private

  def item_key
    :event
  end

  def permitted_item_data(event_data)
    if event_data.respond_to?(:permit)
      event_data.permit(:event_type, :user_id, :timestamp, properties: {}).to_h
    else
      event_data
    end
  end

  def required_params
    %w[event_type user_id properties timestamp]
  end

  def process_valid_item(valid_event)
    super("event", valid_event)
  end
end
