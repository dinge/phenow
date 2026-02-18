# frozen_string_literal: true

module FormHelper
  # Returns the appropriate CSS class for a form input field
  # Adds error class if the field has validation errors
  #
  # @param record [ActiveRecord::Base] The model instance
  # @param field [Symbol, String] The field name
  # @return [String] CSS class string
  def form_input_class(record, field)
    if record&.errors&.[](field)&.any?
      "form-input form-input-error"
    else
      "form-input"
    end
  end

  # Returns error message paragraph for a field if errors exist
  #
  # @param record [ActiveRecord::Base] The model instance
  # @param field [Symbol, String] The field name
  # @return [String, nil] HTML paragraph with error message or nil
  def error_for(record, field)
    return unless record&.errors&.[](field)&.any?

    content_tag(:p, record.errors[field].first, class: "form-error")
  end
end
