class Invitations::RegistrationsController < ApplicationController
  before_filter :ensure_invitation!
  before_filter :redirect_signed_in_user, only: :new

  def new
    @signup = Invitation::Registration.new
    @signup.invitation = @invitation
  end

  def create
    @signup = Invitation::Registration.new(params[:registration])
    @signup.invitation = @invitation

    if @signup.save
      sign_in @signup.user
      redirect_to projects_path,
        notice: 'Thanks for signing up.'
    else
      render action: :new
    end
  end

  private

  def ensure_invitation!
    code = params[:code] ||
      params[:registration] && params[:registration][:code] ||
      params[:join] && params[:join][:code]

    code.present? or
      return redirect_to root_path, alert: 'Please provide a valid invitation code.'

    @invitation = Invitation.where(code: code).first

    @invitation.present? or
      return redirect_to root_path, alert: 'Please provide a valid invitation code.'

    @invitation.used? and
      return redirect_to root_path, alert: 'Your invitation code has already been used.'
  end

  def redirect_signed_in_user
    user_signed_in? and
      redirect_to new_invitations_join_path(code: @invitation.code)
  end
end
