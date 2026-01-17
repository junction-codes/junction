# frozen_string_literal: true

module AuthenticationHelper
  def self.included(base)
    base.extend(ClassMethods)
    base.fixtures "junction/users"
  end

  def random_password
    Faker::Internet.password(max_length: 72, special_characters: true)
  end

  def sign_in(user:  junction_users(:one), password: "password")
    post session_url, params: { email_address: user.email_address, password: password }
  end

  module ClassMethods
    def requires_authentication(user_name: :one, password: "password")
      before do
        sign_in(user: junction_users(user_name), password:)
      end
    end
  end
end
