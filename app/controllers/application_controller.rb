class ApplicationController < ActionController::Base

  private

  def current_user
    @user ||= User.find(session[:user_id])
  end

  def is_logged_in?
    !!session[:user_id]
  end

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session.clear
    redirect_to root_path
  end

  def valid_creds?
    @user = User.find_by(email: params[:user][:email])
    !!@user && @user.authenticate(params[:user][:password])
  end

  def require_login
    redirect_to login_path unless session.include? :user_id
  end

  def require_logged_out
    redirect_to dashboard_path if session.include? :user_id
  end

end
