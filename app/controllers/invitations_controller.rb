class InvitationsController < AccountController
  def index
    @invitations = account_invitations
  end

  def new
    @invitation = account_invitations.build
  end

  def create
    @invitation = account_invitations.build(invitation_params)
    @invitation.sender = current_user

    if @invitation.save
      @invitation.send_mail!

      redirect_to account_invitations_path(@account),
        notice: "Invitation has been created and mailed."
    else
      render :new
    end
  end

  def destroy
    @invitation = account_invitations.find_by_code!(params[:id])
    @invitation.destroy

    redirect_to account_invitations_path(@account),
      notice: 'Invitation has been destroyed.'
  end

  # Resend the mail with registration link and invitation code
  def resend
    @invitation = account_invitations.find_by_code!(params[:id])
    @invitation.send_mail!

    redirect_to account_invitations_path(@account),
      notice: 'An invitation email has been sent out.'
  end

  private

  def account_invitations
    @account.invitations
  end

  def invitation_params
    params.require(:invitation).permit(:email, :admin, project_ids: [])
  end
end
