class RegistrationsController < ApplicationController
  before_filter :ensure_new_user
  before_filter :load_and_ensure_active_invitation

  def new
    @registration = Registration.new
  end

  def create
    @registration = Registration.new(params[:registration])

    if @registration.save
      sign_in @registration.user
      @invitation.accept!(@registration.user) if @invitation.present?

      redirect_to projects_path, notice: 'Invitation has been accepted. Welcome from the Tweetbox Team.'
    else
      render action: :new
    end
  end

  private

  def ensure_new_user
    user_signed_in? and return redirect_to root_url,
      notice: 'Invitations can only be accepted by new users. Please log out before visiting this URL.'
  end

  def load_and_ensure_active_invitation
    @invitation = Invitation.where(code: params[:invitation_code]).first

    @invitation.present? or return redirect_to root_url,
      notice: 'Please provide a valid invitation code.'

    @invitation.used? and return redirect_to root_url,
      notice: 'Your invitation code has already been used.'

    @invitation.active? or return redirect_to root_url,
      notice: 'The invitation code has expired. Please generate a new one.'
  end
end
