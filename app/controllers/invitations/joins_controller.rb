class Invitations::JoinsController < Invitations::BaseController
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
end
