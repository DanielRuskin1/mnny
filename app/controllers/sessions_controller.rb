class SessionsController < ApplicationController
  # Necessary for authentication
  if !Rails.env.production?
    skip_before_action :verify_authenticity_token
  end

  def create
    if auth_hash.nil?
      flash[:danger] = "Please try again."
    else
      user = User.find_or_create_from_auth_hash!(auth_hash)
      session[:user_id] = user.id

      flash[:success] = "Thanks for signing in!"
    end

    redirect_to(root_path)
  end

  def destroy
    if session[:user_id].nil?
      flash[:success] = "You're not signed in!"
    else
      session[:user_id] = nil

      flash[:success] = "You're signed out!"
    end

    redirect_to(root_path)
  end

  def failure
    flash[:notice] = params[:message]
    redirect_to(root_path)
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end
end
