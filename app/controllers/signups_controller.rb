class SignupsController < ApplicationController
  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(params[:signup])

    if @signup.save
      sign_in @signup.user

      track 'User Create By Signup', @signup.user
      track_user @signup.user, 'Signup'

      track 'Account Create', @signup.account
      track 'Project Create', @signup.project

      track 'Signup Success', @signup.user

      redirect_to projects_path, notice: 'You signed up successfully.'
    else
      track 'Signup Fail', nil, {
        'First Name'   => @signup.first_name,
        'Last Name'    => @signup.last_name,
        'Email'        => @signup.email,
        'Company Name' => @signup.company_name
      }

      render :new
    end
  end
end
