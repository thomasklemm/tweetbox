class AcceptInvitationsController < ApplicationController
  before_filter :save_invitation_code_in_session
  before_filter :ensure_active_invitation!
  before_filter :ensure_current_user_would_be_new_account_member!
  after_filter  :reset_invitation_code_in_session

  def accept
    if user_signed_in?
      @invitation.accept!(current_user)
    else
      redirect_to new_registration_path,
        notice: 'Please register and join your teammates.'
    end
  end

  def accept
    @invitation.accept!(current_user)
    reset_invitation_code_in_session!
    redirect_to projects_path,
      notice: "Welcome aboard! You'll love your customers even more with Birdview."
  end

  private

  def save_invitation_code_in_session
    params[:invitation_code] &&
      session[:invitation_code] = params[:invitation_code]
  end

  def reset_invitation_code_in_session
    session.delete(:invitation_code)
  end

  def ensure_active_invitation!
    @invitation = Invitation.where(code: session[:invitation_code]).first

    @invitation.present? or return redirect_to root_url,
      notice: 'Please provide a valid invitation code.'

    !@invitation.used? or return redirect_to root_url,
      notice: 'Your invitation code has already been used.'

    !@invitation.active? or return redirect_to root_url,
      notice: 'The invitation code has expired. Please generate a new one.'
  end

  def ensure_current_user_would_be_new_account_member!
    if user_signed_in?
      !@invitation.account.has_member?(current_user) or return redirect_to projects_url,
        notice: "Only users who aren't account members yet can accept the invitation."
    end
  end
end
