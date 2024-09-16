class PersonProcessor < BaseProcessor
  private

  def item_key
    :person
  end

  def process_result(item)
    prepared_item = prepare_single_item
    super(prepared_item)
  end

  def prepare_single_item
    prepare_person(@params[item_key])
  end

  def prepare_person(person_data)
    person = permitted_person_data(person_data)
    person["context"] = generate_context
    person
  end

  def permitted_person_data(person_data)
    if person_data.respond_to?(:permit)
      person_data.permit(:user_id, :timestamp, traits: {}).to_h
    else
      person_data
    end
  end

  def process_valid_item(valid_person)
    SendPerson.call(valid_person)
  end

  def required_params
    %w[user_id traits timestamp]
  end
end
