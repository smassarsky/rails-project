class InvitationsController < ApplicationController
  before_action :require_login
  before_action :set_matchup
  before_action :only_owner

  def new
    if !@matchup.full?
      @invitation = @matchup.invitations.build
    else
      redirect_to matchup_path(@matchup), alert: "Matchups can only have 4 players"
    end
  end

  def create
    if !@matchup.full?
      @matchup.invitations.create(invitation_params)
      redirect_to matchup_path(@matchup)
    else
      redirect_to matchup_path(@matchup), alert: "Matchups can only have 4 players"
    end
  end

  def destroy
    invitation = Invitation.find_by(id: params[:id])
    if invitation
      invitation.destroy
      redirect_to matchup_path(@matchup)
    else
      redirect_to matchup_path(@matchup), alert: "Invalid Invitation"
    end
  end

  private

  def set_matchup
    @matchup = Matchup.find(params[:matchup_id])
  end

  def only_owner
    redirect_to matchup_path(@matchup), alert: "You can't do that" if !owner?(@matchup)
  end

  def invitation_params
    params.require(:invitation).permit(:nickname)
  end

end
