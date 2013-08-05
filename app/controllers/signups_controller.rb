class SignupsController < ApplicationController
  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(params[:signup])

    if @signup.save
      track_activity @signup.user, :sign_up
      track_activity @signup.account, :create
      track_activity @signup.project, :create

      sign_in @signup.user
      redirect_to projects_path, notice: 'You signed up successfully.'
    else
      render :new
    end
  end
end
