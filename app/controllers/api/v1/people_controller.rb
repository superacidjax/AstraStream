class Api::V1::PeopleController < ApplicationController
  # POST /api/v1/people
  def create
    person_data = person_params.to_h
    if missing_required_params.present?
      render_error(missing_required_params)
    else
      person_data["context"]["application_id"] = @api_key.application_id
      SendPerson.call(person_data)
      render json: person_data, status: :created
    end
  end

  def person_params
    params.require(:person).permit(
      :user_id,
      :timestamp,
      traits: {},
      context: {}
    )
  end

  def render_error(missing_params)
    render json: {
      error: "Missing required parameters: #{missing_params.join(', ')}"
    },
    status: :bad_request
  end

  def missing_required_params
    required_params = [ :user_id, :traits, :timestamp ]
    required_params.select { |param| person_params[param].blank? }
  end
end
