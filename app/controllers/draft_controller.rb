class DraftController < ApplicationController
  before_action :require_login

  def draft_table
    @matchup = Matchup.find(params[:matchup_id])
  end

  def pick

  end

end