class EventProcessor < BaseProcessor
  private

  def item_key
    :event
  end

  def process_result(item)
    # Process only a single event
    prepared_item = prepare_single_item
    super(prepared_item) # Pass the single item directly
  end

  def prepare_single_item
    prepare_event(@params[item_key])
  end

  def prepare_event(event_data)
    # Prepare the permitted event data and ensure context is generated
    event = permitted_event_data(event_data)
    event[:context] = generate_context unless event.key?(:context)
    event
  end

  def permitted_event_data(event_data)
    # Permit only the necessary parameters
    if event_data.respond_to?(:permit)
      event_data.permit(:event_type, :user_id, :timestamp, properties: {}).to_h
    else
      event_data
    end
  end

  def process_valid_item(valid_event)
    # Processing a single valid event
    SendEvent.call(valid_event)
  end

  def required_params
    %w[event_type user_id properties timestamp]
  end

  def process_or_log_errors(event)
    errors = []
    missing_params = find_missing_required_params(event)

    if missing_params.present?
      errors << {
        event: event,
        error: "Missing required parameters: #{missing_params.join(', ')}"
      }
    else
      process_valid_item(event)
    end

    errors
  end
end