class PersonProcessor < BaseProcessor
  include ItemValidator

  private

  def item_key
    :person
  end

  def permitted_item_data(person_data)
    return person_data unless person_data.respond_to?(:permit)

    permitted = person_data.permit(:user_id, :timestamp).to_h
    traits = validate_items(person_data[:traits], "traits")
    return if @status == :bad_request

    permitted["traits"] = traits
    permitted
  end

  def required_params
    %w[user_id traits timestamp]
  end

  def process_valid_item(valid_person)
    SendPersonJob.perform_later(valid_person)
  end
end
