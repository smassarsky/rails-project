class MatchupsController < ApplicationController
  before_action :require_login
  before_action :set_matchup, only: [:show, :edit, :update, :destroy, :remove_user_matchup, :draft_start]
  before_action :only_owner, only: [:edit, :update, :destroy, :remove_user_matchup, :draft_start]
  before_action :only_users, only: [:show]
  before_action :only_pre_draft, only: [:edit, :update, :remove_user_matchup]

  def index
    @matchups = current_user.matchups
    @owned_matchups = current_user.owned_matchups
  end

  def new
    @matchup = Matchup.new
  end

  def create
    @matchup = current_user.owned_matchups.build(matchup_params)
    if @matchup.save
      @matchup.users << current_user
      @matchup.save
      redirect_to matchup_path(@matchup)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @matchup.update(matchup_params)
      redirect_to matchup_path(@matchup)
    else
      render :edit
    end
  end
  
  def destroy
    @matchup.destroy
    redirect_to matchups_path
  end

  def draft_start
    if @matchup.users_count > 1
      delete_extra_invitations
      @matchup.update(status: "Draft")
      set_draft_order
      redirect_to matchup_path(@matchup)
    else
      redirect_to matchup_path(@matchup), alert: "Not enough players"
    end
  end

  def join
  end

  def confirm
    @invitation = Invitation.find_by(code: params[:invitation][:code])
    if @invitation
      @matchup = @invitation.matchup
    else
      redirect_to matchups_join_path, alert: "Invitation not valid"
    end
  end

  def link_user
    @invitation = Invitation.find_by(code: params[:code])
    if @invitation
      @matchup = @invitation.matchup
      if !@matchup.users.include?(current_user)
        @matchup.user_matchups.build(user: current_user, nickname: @invitation.nickname.empty? || @invitation.nickname == current_user.name ? nil : @invitation.nickname)
        @matchup.save
        @invitation.destroy
        redirect_to matchup_path(@matchup)
      else
        render :join, alert: "You've already joined that matchup"
      end
    end
  end

  def remove_user_matchup
    user_matchup = UserMatchup.find_by(id: params[:id])
    if user_matchup && user_matchup.user != current_user
      user_matchup.destroy
      redirect_to matchup_path(@matchup)
    else
      redirect_to matchup_path(@matchup), alert: "Invalid User"
    end
  end

  # get '/matchups/join', to: 'matchups#join'
  # get '/matchups/join/:code', to: 'matchups#confirm'
  # post '/matchups/join/:code', to: 'matchups#link_user'

  private

  def matchup_params
    params.require(:matchup).permit(:name, :start_date, :end_date, :team_id)
  end

  def set_matchup
    if params[:matchup_id]
      @matchup = Matchup.find(params[:matchup_id])
    else
      @matchup = Matchup.find(params[:id])
    end
  end


  def only_users
    redirect_to matchups_path, alert: "You can't do that" if !@matchup.users.include?(current_user)
  end

  def delete_extra_invitations
    @matchup.invitations.destroy_all
  end

  def set_draft_order
    @matchup.user_matchups.order('random()').each_with_index do |usermatchup, index|
      usermatchup.update(draft_order: index)
    end
  end

end
