class Api::V1::EventsController < ApplicationController
  def create
    processor = EventProcessor.new(params: params, api_key: @api_key)
    processor.process
    render json: processor.result, status: processor.status
  end
end
