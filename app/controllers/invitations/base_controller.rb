class Invitations::BaseController < ApplicationController
  before_filter :ensure_invitation

  private

  def ensure_invitation
    code = params[:code]
    code.present? or
      return redirect_to root_path, alert: 'Please provide a valid invitation code.'

    @invitation = Invitation.where(code: code).first

    @invitation.present? or
      return redirect_to root_path, alert: 'Please provide a valid invitation code.'

    @invitation.used? and
      return redirect_to root_path, alert: 'Your invitation code has already been used.'
  end
end
