class Api::V1::EventsController < ApplicationController
  before_action :authenticate_api_request

  # POST /api/v1/events
  def create
    event_data = event_params.to_h
    event_data[:application_id] = @api_key.application_id
    # TODO Background this
    SendToWarehouse.call(event_data)
    render json: event_data, status: :created
  end

  def event_params
    params.require(:event).permit(:event_type, :user_id, data: {})
  end
end
