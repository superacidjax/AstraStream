class Api::V1::PeopleController < ApplicationController
  def create
    processor = PersonProcessor.new(params: params, api_key: @api_key)
    processor.process
    render json: processor.result, status: processor.status
  end
end
