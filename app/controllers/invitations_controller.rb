class InvitationsController < ApplicationController
  before_action :require_login
  before_action :set_matchup
  before_action :only_owner
  before_action :redirect_if_full, only: [:new, :create]
  before_action :set_invitation, only: [:edit, :update, :destroy]
  before_action :only_pre_draft

  def new
    @invitation = @matchup.invitations.build
  end

  def create
    @matchup.invitations.create(invitation_params)
    redirect_to matchup_path(@matchup)
  end

  def edit
  end

  def update
    @invitation.update(invitation_params)
    redirect_to matchup_path(@matchup), notice: "Nickname updated!"
  end

  def destroy
    @invitation.destroy
    redirect_to matchup_path(@matchup), notice: "Invitation deleted!"
  end

  private

  def set_matchup
    @matchup = Matchup.find(params[:matchup_id])
    redirect_to matchups_path if !@matchup
  end

  def set_invitation
    @invitation = Invitation.find_by(id: params[:id])
    redirect_to matchup_path(@matchup), alert: "Invalid invitation." if !@invitation || @invitation.owner != @matchup.owner
  end

  def only_owner
    redirect_to matchup_path(@matchup), alert: "You can't do that" if !owner?(@matchup)
  end

  def redirect_if_full
    redirect_to matchup_path(@matchup), alert: "Matchups can only have 4 players" if @matchup.full?
  end

  def invitation_params
    params.require(:invitation).permit(:nickname)
  end

end
