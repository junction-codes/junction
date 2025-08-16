# frozen_string_literal: true

class PasswordValidator < ActiveModel::EachValidator
  PASSWORD_RULES = {
    /[a-z]/ => "lowercase letter",
    /[A-Z]/ => "uppercase letter",
    /\d/    => "digit",
    /[^A-Za-z0-9]/ => "special character"
  }.freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    PASSWORD_RULES.each do |regex, requirement|
      record.errors.add(attribute, " must contain at least one #{requirement}") unless value.match(regex)
    end
  end
end
