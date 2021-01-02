class UserMatchupsController < ApplicationController
  before_action :require_login
  before_action :set_user_matchup
  before_action :only_users

  def show
  end


  private

  def set_user_matchup
    @user_matchup = UserMatchup.find_by(id: params[:id])
  end
  
  def only_users
    redirect_to matchups_path, alert: "You can't do that" if !@user_matchup.matchup.users.include?(current_user)
  end

end
