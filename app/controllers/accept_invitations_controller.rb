class AcceptInvitationsController < ApplicationController
  before_filter :ensure_unused_invitation!
  before_filter :ensure_current_user!

  def accept
    @invitation.accept!(current_user)
    reset_invitation_code_in_session!
    redirect_to projects_path, notice: "Welcome aboard! You'll love your customers even more with Birdview."
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

  def ensure_unused_invitation!
    @invitation = Invitation.where(code: invitation_code).first

    @invitation.present? or return redirect_to root_url,
      notice: 'Please provide a valid invitation code.'

    !@invitation.used? or return redirect_to root_url,
      notice: 'Your invitation code has already been used.'
  end

  def ensure_current_user!
    user_signed_in? or return redirect_to new_user_registration_url,
      notice: 'Please register before accepting your invitation.'
  end
end
