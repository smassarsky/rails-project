class MatchupsController < ApplicationController
  before_action :require_login
  before_action :set_matchup, only: [:show, :edit, :update, :destroy, :remove_user_matchup, :start_draft]
  before_action :only_owner, only: [:edit, :update, :destroy, :remove_user_matchup, :start_draft]
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
      redirect_to @matchup
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
      redirect_to @matchup
    else
      render :edit
    end
  end
  
  def destroy
    @matchup.destroy
    redirect_to matchups_path
  end

  def start_draft
    if @matchup.start_draft
      redirect_to @matchup
    else
      redirect_to @matchup, alert: "Not enough players"
    end
  end

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

end
