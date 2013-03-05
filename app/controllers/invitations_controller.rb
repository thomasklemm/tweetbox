class InvitationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_account
  after_filter :verify_authorized

  def index
    @invitations = @account.invitations
  end

  def new
    @invitation = @account.invitations.build
  end

  def create
    @invitation = @account.invitations.build(invitation_params)
    @invitation.sender = current_user

    if @invitation.save
      @email_sent = @invitation.send_email

      redirect_to account_invitations_path(@account),
        notice: 'Invitation was successfully created.'
    else
      render action: :new
    end
  end

  # TODO: maybe don't destroy invitations when they have been used
  def destroy
    @invitation = @account.invitations.find_by_code!(params[:id])
    @invitation.destroy
    redirect_to account_invitations_path(@account),
      notice: 'Invitation was successfully destroyed.'
  end

  def send_email
    @invitation = @account.invitations.find_by_code!(params[:id])
    @email_sent = @invitation.send_email
    redirect_to account_invitations_path(@account),
      notice: 'Invitation email was successfully sent.'
  end

  private

  def load_and_authorize_account
    @account = user_account
    authorize @account, :invite?
  end

  def invitation_params
    params.require(:invitation).permit(:email, :admin, project_ids: [])
  end
end
