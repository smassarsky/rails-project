class ApplicationController < ActionController::Base

  private

  def current_user
    @user ||= User.find(session[:user_id])
  end

  def log_in
    session[:user_id] = @user.id
  end

  def is_logged_in?
    !!session[:user_id]
  end

  def require_login
    redirect_to login_path unless session.include? :user_id
  end

  def require_logged_out
    redirect_to dashboard_path if session.include? :user_id
  end

  def owner?(thing)
    thing.owner == current_user
  end

  def only_pre_draft
    redirect_to matchup_path(@matchup), alert: "Matchup cannot be modified after draft has started." if @matchup.status != "Pre-Draft"
  end

  def only_owner
    redirect_to matchup_path(@matchup), alert: "You can't do that" if !owner?(@matchup)
  end

end
