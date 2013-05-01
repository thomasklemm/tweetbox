class InvitationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_account
  after_filter :verify_authorized

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
      @sent_mail = @invitation.send_mail!

      redirect_to account_invitations_path(@account),
        notice: "You've invited a colleague of yours successfully."
    else
      render action: :new
    end
  end

  def destroy
    @invitation = account_invitations.find_by_code!(params[:id])
    @invitation.destroy

    redirect_to account_invitations_path(@account),
      notice: 'Invitation was successfully destroyed.'
  end

  # Resend the mail with registration link and invitation code
  def send_mail
    @invitation = account_invitations.find_by_code!(params[:id])
    @sent_mail = @invitation.send_mail!

    redirect_to account_invitations_path(@account),
      notice: 'Invitation mail was successfully sent.'
  end

  private

  def load_and_authorize_account
    @account = user_account
    authorize @account, :invite?
  end

  def account_invitations
    @account.invitations
  end

  def invitation_params
    params.require(:invitation).permit(:email, :admin, project_ids: [])
  end
end
