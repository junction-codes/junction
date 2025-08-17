# frozen_string_literal: true

module AuthenticationHelper
  def self.included(base)
    base.extend(ClassMethods)
    base.fixtures :users
  end

  def sign_in(user:  users(:one), password: "password")
    post session_url, params: { email_address: user.email_address, password: password }
  end

  module ClassMethods
    def requires_authentication(user_name: :one, password: "password")
      before do
        sign_in(user: users(user_name), password:)
      end
    end
  end
end
