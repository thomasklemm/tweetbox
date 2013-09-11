class SignupsController < ApplicationController
  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(params[:signup])

    if @signup.save
      sign_in @signup.user

      # Internal tracking
      track_activity @signup.user, :sign_up
      track_activity @signup.account, :create
      track_activity @signup.project, :create

      # Mixpanel tracking
      unless Rails.env.test?
        UserTracker.new(@signup.user).track_create_by_signup
        AccountTracker.new(@signup.account, current_user).track_create
        ProjectTracker.new(@signup.project, current_user).track_create
      end

      redirect_to projects_path, notice: 'You signed up successfully.'
    else
      render :new
    end
  end
end
