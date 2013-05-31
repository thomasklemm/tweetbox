class InvitationsController < AccountController
  before_filter :load_invitation, only: [:destroy, :deliver_mail]

  def index
    @invitations = account_invitations
  end

  def new
    @invitation = account_invitations.build
  end

  def create
    @invitation = account_invitations.build(invitation_params)

    if @invitation.save
      @invitation.deliver_mail
      redirect_to account_path, notice: "Invitation has been created and mailed."
    else
      render :new
    end
  end

  def destroy
    @invitation.destroy
    redirect_to account_path, notice: 'Invitation has been destroyed.'
  end

  # Send invitation mail once again
  def deliver_mail
    @invitation.deliver_mail
    redirect_to account_path, notice: 'Invitation email has been sent.'
  end

  private

  def account_invitations
    @account.invitations
  end

  def account_invitation
    account_invitations.find_by_code!(params[:id])
  end

  def load_invitation
    @invitation = account_invitation
  end

  def invitation_params
    params.require(:invitation).permit(:email, :admin, { project_ids: [] }).merge(issuer: current_user)
  end
end
