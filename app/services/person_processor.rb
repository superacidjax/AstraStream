class PersonProcessor < BaseProcessor
  private

  def item_key
    :person
  end

  def permitted_item_data(person_data)
    if person_data.respond_to?(:permit)
      person_data.permit(:user_id, :timestamp, traits: {}).to_h
    else
      person_data
    end
  end

  def required_params
    %w[user_id traits timestamp]
  end

  def process_valid_item(valid_person)
    SendPersonJob.perform_now(valid_person)
  end
end
