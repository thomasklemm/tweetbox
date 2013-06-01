class InvitationsController < AccountController
  before_filter :load_invitation, only: [:edit, :update, :deactivate, :reactivate, :deliver_mail]
  before_filter :ensure_invitation_is_active, only: [:edit, :update]

  def index
    @invitations = account_invitations.decorate
  end

  def new
    @invitation = account_invitations.build
  end

  def create
    @invitation = account_invitations.build(invitation_params)

    if @invitation.save
      @invitation.deliver_mail
      redirect_to account_invitations_path, notice: "Invitation has been created and mailed."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @invitation.update_attributes(invitation_params)
      redirect_to account_invitations_path, notice: "Invitation has been updated."
    else
      render :edit
    end
  end

  def deactivate
    @invitation.deactivate!
    redirect_to :back, notice: 'Invitation has been deactivated.'
  end

  def reactivate
    @invitation.reactivate!
    redirect_to :back, notice: 'Invitation has been reactivated.'
  end

  # Send invitation mail once again
  def deliver_mail
    @invitation.deliver_mail
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
    params.require(:invitation).permit(:name, :email, { project_ids: [] }).merge(issuer: current_user)
  end
end
