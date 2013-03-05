class InvitationSignupsController < ApplicationController
  before_filter :ensure_invitation

  # Store the invitation code for the next step
  def new
    @signup = InvitationSignup.new
    @signup.invitation = @invitation
  end

  # Create a new user and accept invitation
  def create
    @signup = InvitationSignup.new(params[:signup])
    @signup.invitation = @invitation

    if @signup.save
      sign_in @signup.user
      redirect_to projects_path, notice: 'You signed up successfully.'
    else
      render action: :new
    end
  end

  # Accept an invitation for an existing user
  def accept
    @signup = InvitationSignup.new(params[:signup])
    @signup.invitation = @invitation
    @signup.user = current_user
  end

  private

  def ensure_invitation
    begin
      # Provide invitation code in these parameters
      code = params[:code] || params[:signup][:code]
      @invitation = Invitation.find_by_code!(code)
    rescue ActiveRecord::RecordNotFound
      return redirect_to root_path, alert: 'Please provide a valid invitation code.'
    end

    if @invitation.used?
      return redirect_to root_path, alert: 'Your invitation code has already been used.'
    end
  end
end
