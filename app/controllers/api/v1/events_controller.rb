class Api::V1::EventsController < ApplicationController
  # POST /api/v1/events
  def create
    if single_event?
      handle_single_event
    elsif batch_event?
      handle_batch_event
    else
      render_error(["No valid event or events array provided"])
    end
  end

  private

  def set_api_key
    # Assuming @api_key should be set via some authentication mechanism.
    @api_key = ApiKey.find_by(api_secret: extract_api_secret_from_header)
    if @api_key.blank?
      render json: { error: "API key not found or invalid" }, status: :unauthorized
    end
  end

  def single_event?
    params[:event].present?
  end

  def batch_event?
    params[:events].present? && params[:events].is_a?(Array)
  end

  def handle_single_event
    event_data = prepare_single_event
    errors = process_or_render_error([ event_data ])

    if errors.empty?
      render json: event_data, status: :created
    else
      render_error(errors.map { |e| e[:missing_params] })
    end
  end

  def handle_batch_event
    events = params[:events].map { |event_data| prepare_batch_event(event_data) }
    errors = process_or_render_error(events)

    if errors.present?
      render json: { error: "Some events have missing parameters", details: errors }, status: :bad_request
    else
      render json: { message: "All events created successfully" }, status: :created
    end
  end

  def prepare_single_event
    event_data = event_params.to_h
    event_data[:context] = generate_context
    event_data
  end

  def prepare_batch_event(event_data)
    permitted_event = permit_event(event_data)
    permitted_event[:context] = generate_context
    permitted_event
  end

  def process_or_render_error(events)
    errors = []
    events.each_with_index do |event_data, index|
      missing_params = find_missing_required_params(event_data)
      if missing_params.present?
        errors << { index: index, missing_params: missing_params }
      end
    end

    if errors.empty?
      # Send events to SendEvent in bulk
      SendEvent.call(events)
    end

    errors
  end

  def event_params
    params.require(:event).permit(:event_type, :user_id, :timestamp, properties: {})
  end

  def permit_event(event_data)
    event_data.permit(:event_type, :user_id, :timestamp, properties: {}).to_h
  end

  def find_missing_required_params(event_data)
    required_params = [ :event_type, :user_id, :properties, :timestamp ]
    required_params.select { |param| event_data[param].blank? }
  end

  def render_error(missing_params)
    render json: { error: "Missing required parameters: #{missing_params.join(', ')}" }, status: :bad_request
  end

  def generate_context
    # Ensure @api_key is correctly set
    raise ArgumentError, "API key not set" if @api_key.blank?

    { application_id: @api_key.application_id, generated_at: Time.current.iso8601 }
  end
end
