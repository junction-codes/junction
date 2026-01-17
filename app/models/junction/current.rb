# frozen_string_literal: true

module Junction
  class Current < ActiveSupport::CurrentAttributes
    attribute :session
    delegate :user, to: :session, allow_nil: true
  end
end
