class SignupsController < ApplicationController
  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(params[:signup])

    if @signup.save
      redirect_to project_path(@signup.project), notice: 'You signed up successfully.'
    else
      render action: :new
    end
  end
end
