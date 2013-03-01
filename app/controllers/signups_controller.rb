class SignupsController < ApplicationController
  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(params[:signup])

    if @signup.save
      sign_in @signup.user
      redirect_to projects_path, notice: 'You signed up successfully.'
    else
      render action: :new
    end
  end
end
