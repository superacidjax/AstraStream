# app/services/concerns/item_validator.rb
module ItemValidator
  extend ActiveSupport::Concern

  included do
    private

    def validate_items(items, item_name)
      unless items.present? && items.is_a?(Array)
        return set_bad_request("#{item_name.capitalize} must be present and an array.")
      end

      validated_items = items.map do |item|
        permitted_item = item.permit!  # Allow dynamic keys
        unless permitted_item["type"].present? && valid_item_type?(permitted_item["type"])
          return set_bad_request("Each #{item_name.singularize} must include a valid type.")
        end
        if (permitted_item.keys - [ "type" ]).empty?
          return set_bad_request("Each #{item_name.singularize} must include a key-value pair in addition to 'type'.")
        end
        permitted_item.to_h
      end

      validated_items
    end

    def valid_item_type?(type)
      %w[numeric string datetime boolean].include?(type)
    end

    def set_bad_request(message)
      @status = :bad_request
      @result = { errors: [ message ] }
      nil
    end
  end
end
