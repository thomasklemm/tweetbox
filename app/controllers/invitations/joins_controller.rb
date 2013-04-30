class Invitations::JoinsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_invitation!

  def new
    @join = Invitation::Join.new

    @join.invitation = @invitation
    @join.user = current_user
  end

  def create
    @join = Invitation::Join.new(params[:join])

    @join.invitation = @invitation
    @join.user = current_user

    if @join.save
      redirect_to projects_path,
        notice: "You successfully accepted the invitation."
    else
      render :new
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
end
