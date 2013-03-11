class Invitations::SignupsController < Invitations::BaseController
  before_filter :redirect_signed_in_user, only: :new

  def new
    @signup = Invitation::Signup.new
    @signup.invitation = @invitation
  end

  def create
    @signup = Invitation::Signup.new(params[:signup])
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

  def redirect_signed_in_user
    user_signed_in? and
      redirect_to new_invitations_join_path(code: @invitation.code)
  end
end
