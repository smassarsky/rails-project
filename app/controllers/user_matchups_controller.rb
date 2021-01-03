class UserMatchupsController < ApplicationController
  before_action :require_login
  before_action :set_user_matchup, except: [:new, :confirm, :create]
  before_action :set_matchup, only: [:destroy]
  before_action :only_users, only: [:show]
  before_action :only_user_or_owner, except: [:show, :new, :confirm, :create]
  before_action :cant_delete_owner, only: [:destroy]
  before_action :only_pre_draft, only: [:destroy]

  def show
  end

  def new
  end

  def confirm
    set_invitation_and_checks(params[:invitation][:code])
  end

  def create
    set_invitation_and_checks(params[:code])
    @matchup = @invitation.matchup
    @matchup.user_matchups.build(user: current_user, nickname: @invitation.nickname == current_user.name ? nil : @invitation.nickname)
    @matchup.save
    @invitation.destroy
    redirect_to @matchup
  end

  def edit
  end

  def update
    @user_matchup.update(user_matchup_params)
    redirect_to @user_matchup.matchup, notice: "Nickname updated!"
  end

  def destroy
    @user_matchup.destroy
    redirect_to (owner?(@matchup) ? @matchup : matchups_path), notice: "UserMatchup deleted!"
  end

  private

  def set_user_matchup
    @user_matchup = UserMatchup.find_by(id: params[:id])
    redirect_to matchup_path(params[:matchup_id]) if !@user_matchup
  end

  def set_matchup
    @matchup = Matchup.find_by(id: params[:matchup_id])
  end
  
  def only_users
    redirect_to matchups_path, alert: "You can't do that!" if !@user_matchup.matchup.users.include?(current_user)
  end

  def only_user_or_owner
    redirect_to matchup_path(@user_matchup.matchup), alert: "You can't do that!" if !@user_matchup.owner_or_user?(current_user)
  end

  def cant_delete_owner
    redirect_to @matchup, alert: "Can't delete matchup owner." if @user_matchup.user == @user_matchup.owner
  end

  def only_pre_draft
    redirect_to @matchup, alert: "Can't remove users after draft has started." if !@matchup.is_pre_draft?
  end

  def set_invitation_and_checks(code)
    byebug
    @invitation = Invitation.find_by(code: code)
    redirect_to new_user_matchup_path, alert: "Invalid invitation" and return if @invitation.nil?
    redirect_to new_user_matchup_path, alert: "You've already joined that matchup" and return if @invitation.matchup.users.include?(current_user)
  end

  def user_matchup_params
    params.require(:user_matchup).permit(:nickname)
  end

end
