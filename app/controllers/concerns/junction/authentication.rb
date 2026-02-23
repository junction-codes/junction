# frozen_string_literal: true

module Junction
  module Authentication
    extend ActiveSupport::Concern

  included do
    before_action :require_authentication, unless: :demo_mode?
    helper_method :authenticated?
    helper_method :current_user
    helper_method :demo_mode?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def demo_mode?
    Junction.config.allow_demo_mode && !user_authenticated?
  end

  def user_authenticated?
    resume_session.present?
  end

  def authenticated?
    resume_session
  end

  def current_user
    Junction::Current.user
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Junction::Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Junction::Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end


    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Junction::Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Junction::Current.session.destroy
      cookies.delete(:session_id)
    end
  end
end
