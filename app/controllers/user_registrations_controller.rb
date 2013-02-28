class UserRegistrationsController < Devise::RegistrationsController
  def new
    flash[:notice] = 'Please use the signup form to register.'
    redirect_to root_path
  end

  def create
    flash[:notice] = 'Please use the signup form to register.'
    redirect_to root_path
  end
end
