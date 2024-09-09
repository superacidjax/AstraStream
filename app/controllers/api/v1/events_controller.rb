class Api::V1::EventsController < ApplicationController
  before_action :authenticate_api_request

  # POST /api/v1/events
  def create
    event_data = event_params.to_h
    if missing_required_params.present?
      render_error(missing_required_params)
    else
      event_data[:application_id] = @api_key.application_id
      SendToWarehouse.call(event_data)
      render json: event_data, status: :created
    end
  end

  def event_params
    params.require(:event).permit(:event_type, :user_id, data: {})
  end

  def render_error(missing_params)
    render json: {
      error: "Missing required parameters: #{missing_params.join(', ')}"
    },
    status: :bad_request
  end

  def missing_required_params
    required_params = [ :event_type, :user_id ]
    required_params.select { |param| event_params[param].blank? }
  end
end
