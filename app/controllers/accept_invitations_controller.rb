class AcceptInvitationsController < ApplicationController
  before_filter :ensure_active_invitation!
  before_filter :ensure_signed_in_user!
  before_filter :ensure_new_user_on_account!

  def accept
    @invitation.accept!(current_user)
    reset_invitation_code_in_session!
    redirect_to projects_path,
      notice: "Welcome aboard! You'll love your customers even more with Birdview."
  end

  private

  def invitation_code
    code = params[:invitation_code] || session[:invitation_code]
    session[:invitation_code] ||= code
    code
  end

  def reset_invitation_code_in_session!
    session.delete(:invitation_code)
  end

  def ensure_active_invitation!
    @invitation = Invitation.where(code: invitation_code).first

    @invitation.present? or return redirect_to root_url,
      notice: 'Please provide a valid invitation code.'

    !@invitation.used? or return redirect_to root_url,
      notice: 'Your invitation code has already been used.'

    !@invitation.active? or return redirect_to root_url,
      notice: 'The invitation code has expired. Please generate a new one.'
  end

  def ensure_signed_in_user!
    user_signed_in? or return redirect_to new_user_registration_url,
      notice: 'Please register before accepting your invitation.'
  end

  def ensure_new_user_on_account!
    !@invitation.account.has_member?(current_user) or return redirect_to projects_url,
      notice: "Only users who aren't account members yet can accept the invitation."
  end
end
