class RegistrationsController < ApplicationController
  before_action :load_and_ensure_active_invitation, only: :new

  def new
    @registration = Registration.new(invitation_params)
  end

  # Create new user and accept invitation
  def create
    @registration = Registration.new(registration_params)

    if @registration.save
      sign_in @registration.user

      # Pass user to track on the right user, because the current user might still be
      #   the signed in creator of the invitation
      track 'User Create By Invitation', @registration.user, { user: @registration.user }
      track_user @registration.user, 'Invitation'

      track 'Invitation Accept', @registration.invitation, { user: @registration.user }
      track 'Account Join', @registration.account, { user: @registration.user }

      redirect_to projects_path,
        notice: "Welcome to Tweetbox."
    else
      render :new
    end
  end

  private

  def invitation_params
    params.slice(:invitation_token, :first_name, :last_name, :email)
  end

  def registration_params
    params[:registration].slice(:invitation_token, :first_name, :last_name, :email, :password)
  end

  def load_and_ensure_active_invitation
    invitation_token = params[:invitation_token]
    invitation = Invitation.find_by!(token: invitation_token) if invitation_token.present?

    invitation_token.present? or return redirect_to root_url,
      notice: "You'll need an invitation token to successfully register."

    invitation.present? or return redirect_to root_url,
      notice: "The invitation token could not be found or has been revoked."

    invitation.used? and return redirect_to root_url,
      notice: "The invitation token has already been used."

    invitation.expired? and return redirect_to root_url,
      notice: "The invitation token has expired."
  end
end
