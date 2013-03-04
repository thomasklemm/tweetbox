class InvitesController < ApplicationController
  before_filter :authenticate_user!, only: :accept
  before_filter :load_invitation

  def show
  end

  def accept
    # Quit if invite has already been used
    @invitation.used? and
      return redirect_to invite_path(@invitation),
        alert: 'This invite has already been used.'

    # Create membership
    # Membership.create! do |m|
    #   m.user = current_user
    #   m.account = @invitation.account
    #   m.admin = @invitation.admin
    # end

    # TODO: Create permissions

    # Mark invitation as used
    @invitation.update_column(:used, true)

    redirect_to projects_path,
      notice: 'Invitation successfully accepted.'
  end

  private

  def load_invitation
    @invitation = Invitation.where(code: params[:id]).first!
  end
end
