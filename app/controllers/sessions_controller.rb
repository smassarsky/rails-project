class SessionsController < ApplicationController
  before_action :require_login, only: [:dashboard, :destroy]
  before_action :require_logged_out, only: [:new, :create, :welcome]

  def welcome
  end

  def new
    @user = User.new
  end

  def create
    # google login
    if params[:provider]
      @user = User.find_or_create_by(email: auth[:extra][:id_info][:email]) do |u|
        u.name = auth[:extra][:id_info][:given_name]
        u.password = u.password_confirmation = SecureRandom.urlsafe_base64
      end
      log_in
      redirect_to dashboard_path

    # regular login
    else
      if valid_creds?
        log_in
        redirect_to dashboard_path
      else
        redirect_to login_path, alert: "Invalid Credentials"
      end
    end
  end

  def destroy
    log_out
  end

  def dashboard
    current_user
  end

  private

  def valid_creds?
    @user = User.find_by(email: params[:user][:email])
    !!@user && @user.authenticate(params[:user][:password])
  end



  def log_out
    session.clear
    redirect_to root_path
  end

  def auth
    request.env['omniauth.auth']
  end

end
