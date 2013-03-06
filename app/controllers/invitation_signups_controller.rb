class InvitationSignupsController < ApplicationController
  before_filter :ensure_invitation

  # Store the invitation code for the next step
  def new
  end

  # Create a new user and accept invitation
  def create
    @signup.name     = params[:signup][:name]
    @signup.email    = params[:signup][:email]
    @signup.password = params[:signup][:password]

    if @signup.save
      sign_in @signup.user
      redirect_to projects_path, notice: 'You signed up successfully.'
    else
      render action: :new
    end
  end

  # Accept an invitation for an existing user
  def accept
    user_signed_in? or return redirect_to new_invitation_signup_path,
      notice: 'You need to be signed in to accept an invitation.'

    @signup.user = current_user

    if @signup.save
      redirect_to projects_path, notice: 'You accepted the invitation successfully.'
    else
      render action: :new
    end
  end

  private

  def ensure_invitation
    # Provide invitation code in these parameters
    code = params[:code] || params[:signup] && params[:signup][:code]

    @signup = InvitationSignup.new(code)

    @signup.invitation.present? or
      return redirect_to root_path, alert: 'Please provide a valid invitation code.'

    @signup.invitation.used? and
      return redirect_to root_path, alert: 'Your invitation code has already been used.'
  end
end
