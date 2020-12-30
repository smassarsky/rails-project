class PicksController < ApplicationController
  before_action :require_login

  def create
    @matchup = Matchup.find_by(id: params[:matchup_id])
    if my_pick?(@matchup)
      @user_matchup = UserMatchup.find_by(matchup: @matchup, user: current_user)
      @player = Player.find_by(id: params[:player_id])
      @user_matchup.picks.build(player: @player) if valid_pick?(@player)
      @user_matchup.save
      if @matchup.draft_done?
        @matchup.end_draft
        redirect_to matchup_path(@matchup)
      else
        redirect_to matchup_draft_table_path(@matchup)
      end
    else
      redirect_to matchup_draft_table_path(@matchup), alert: "It's not your pick!"
    end
  end

  private

  def my_pick?(matchup)
    matchup.whose_pick?.user == current_user
  end

  def valid_pick?(player)
    if @matchup.available_players.include?(player)
      true
    else
      redirect_to matchup_draft_table_path(@matchup), alert: "Invalid Pick"
    end
  end

end