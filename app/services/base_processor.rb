class BaseProcessor
  attr_reader :status, :result

  def initialize(params:, api_key:)
    @params = params
    @api_key = api_key
    @status = nil
    @result = nil
  end

  def process
    item = @params[item_key]
    prepared_item = prepare_item(item)
    process_result(prepared_item)
  end

  private

  def prepare_item(item_data)
    # Permit the necessary parameters and generate context
    permitted_item = permitted_item_data(item_data)
    permitted_item["context"] = generate_context
    permitted_item
  end

  def process_result(item)
    errors = process_or_log_errors(item)

    if errors.present?
      @result = {
        error: errors.first[:error],
        submitted: errors.first[:item]
      }
      @status = :bad_request
    else
      @result = item
      @result[:message] = "Item created successfully"
      @status = :created
    end
  end

  def process_or_log_errors(item)
    errors = []
    missing_params = find_missing_required_params(item)

    if missing_params.present?
      errors << {
        item: item,
        error: "Missing required parameters: #{missing_params.join(', ')}"
      }
    else
      process_valid_item(item)
    end

    errors
  end

  def permitted_item_data(item_data)
    raise NotImplementedError, "Subclasses must define permitted_item_data"
  end

  def item_key
    raise NotImplementedError, "Subclasses must define item_key"
  end

  def required_params
    raise NotImplementedError, "Subclasses must define required_params"
  end

  def process_valid_item(item_type, valid_data)
    send_out_jobs = [
      # SendToRudderstackJob.new(item_type, valid_data),
      SendToAstraAppJob.new(item_type, valid_data)
    ]
    ActiveJob.perform_all_later(send_out_jobs)
  end

  def find_missing_required_params(item)
    return [] unless item.is_a?(Hash)
    required_params.select { |param| item[param].blank? }
  end

  def generate_context
    raise ArgumentError, "API key not set" if @api_key.blank?

    {
      "application_id" => @api_key.application_id,
      "generated_at" => Time.current.iso8601
    }
  end
end
