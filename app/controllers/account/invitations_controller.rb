class Account::InvitationsController < AccountController
  before_filter :load_invitation, only: [:edit, :update, :deactivate, :reactivate, :deliver_mail]
  before_filter :ensure_invitation_is_active, only: [:edit, :update]

  def index
    @invitations = account_invitations.by_date.decorate
  end

  def new
    @invitation = account_invitations.build
  end

  def create
    @invitation = account_invitations.build(invitation_params)

    if @invitation.save
      @invitation.deliver_mail
      track 'Invitation Create', @invitation
      redirect_to account_invitations_path, notice: "Invitation has been created and mailed."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @invitation.update_attributes(invitation_params)
      track 'Invitation Update', @invitation
      redirect_to account_invitations_path, notice: "Invitation has been updated."
    else
      render :edit
    end
  end

  def deactivate
    @invitation.deactivate!
    track 'Invitation Deactivate', @invitation
    redirect_to :back, notice: 'Invitation has been deactivated.'
  end

  def reactivate
    @invitation.reactivate!
    track 'Invitation Reactivate', @invitation
    redirect_to :back, notice: 'Invitation has been reactivated.'
  end

  # Send invitation mail once again
  def deliver_mail
    @invitation.deliver_mail
    track 'Invitation Deliver Mail', @invitation
    redirect_to account_invitations_path, notice: 'Invitation email has been sent.'
  end

  private

  def account_invitations
    user_account.invitations
  end

  def account_invitation
    account_invitations.find_by_code!(params[:id])
  end

  def load_invitation
    @invitation = account_invitation.decorate
  end

  def ensure_invitation_is_active
    @invitation.active? or
      return redirect_to account_invitations_path, notice: 'Only active invitations can be edited.'
  end

  def invitation_params
    permitted_invitation_params.merge(issuer: current_user)
  end

  def permitted_invitation_params
    params.require(:invitation).permit(:first_name, :last_name, :email, { project_ids: [] })
  end
end
