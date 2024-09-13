class Api::V1::PeopleController < ApplicationController
  # POST /api/v1/people
  def create
    if single_person?
      handle_single_person
    elsif batch_people?
      handle_batch_people
    else
      render_error([ "No valid person or people array provided" ])
    end
  end

  private

  def single_person?
    params[:person].present?
  end

  def batch_people?
    params[:people].present? && params[:people].is_a?(Array)
  end

  def handle_single_person
    person_data = prepare_single_person
    errors = find_missing_required_params(person_data) || []  # Ensure errors is an array

    if errors.empty?
      SendPerson.call([ person_data ])  # Wrap in an array for SendPerson
      render json: person_data, status: :created
    else
      render_error(errors)
    end
  end

  def handle_batch_people
    people = params[:people].map { |person_data| prepare_batch_person(person_data) }
    errors = process_or_log_errors(people)

    if errors.present?
      render json: {
        message: "Some people were not processed due to missing parameters",
        details: errors
      }, status: :ok
    else
      render json: { message: "All people created successfully" }, status: :created
    end
  end

  def prepare_single_person
    person_data = person_params.to_h
    person_data["context"] ||= {}  # Ensure context exists
    person_data["context"]["application_id"] = @api_key.application_id
    person_data
  end

  def prepare_batch_person(person_data)
    permitted_person = permit_person(person_data)
    permitted_person["context"] ||= {}  # Ensure context exists
    permitted_person["context"]["application_id"] = @api_key.application_id
    permitted_person
  end

  def process_or_log_errors(people)
    errors = []
    valid_people = []

    people.each_with_index do |person_data, index|
      missing_params = find_missing_required_params(person_data)
      if missing_params.present?
        errors << { person: person_data, error: "Missing required parameters: #{missing_params.join(', ')}" }
      else
        valid_people << person_data
      end
    end

    SendPerson.call(valid_people) if valid_people.any?

    errors
  end

  def person_params
    params.require(:person).permit(:user_id, :timestamp, traits: {}, context: {})
  end

  def permit_person(person_data)
    person_data.permit(:user_id, :timestamp, traits: {}, context: {}).to_h
  end

  def find_missing_required_params(person_data)
    required_params = %w[user_id traits timestamp]
    missing_params = required_params.select { |param| person_data[param].blank? }
    missing_params unless missing_params.empty?
  end

  def render_error(missing_params)
    render json: { error: "Missing required parameters: #{missing_params.join(', ')}" }, status: :bad_request
  end
end
