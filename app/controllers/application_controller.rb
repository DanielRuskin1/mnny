class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    return unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  # before_filter
  def require_current_user
    if current_user.nil?
      redirect_to(root_path, flash: { danger: "You need to sign in first." })
    end

    current_user.nil?
  end
end
