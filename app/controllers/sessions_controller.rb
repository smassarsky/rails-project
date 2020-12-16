class SessionsController < ApplicationController
  before_action :require_login, only: [:dashboard, :destroy]
  before_action :require_logged_out, only: [:new, :create, :welcome]

  def welcome
  end

  def new
    @user = User.new
  end

  def create
    if valid_creds?
      log_in(@user)
      redirect_to dashboard_path
    else
      redirect_to login_path, alert: "Invalid Credentials"
    end
  end

  def destroy
    log_out
  end

  def dashboard
    current_user
  end

end
