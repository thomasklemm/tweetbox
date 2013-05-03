class RegistrationsController < ApplicationController
  before_filter :load_invitation

  def new
    @registration = Registration.new
  end

  def create
    @registration = Registration.new(params[:registration])

    if @registration.save
      sign_in @registration.user

      # Accept invitation if present
      @invitation.accept!(@registration.user) if @invitation.present?

      redirect_to projects_path, notice: 'You registered successfully.'
    else
      render action: :new
    end
  end

  private

  def load_invitation
    @invitation = Invitation.where(code: session[:invitation_code]).first
  end
end
