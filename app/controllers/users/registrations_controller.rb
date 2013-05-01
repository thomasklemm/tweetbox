# Allow Devise to work with strong_parameters
class Users::RegistrationsController < Devise::RegistrationsController
  def resource_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  private :resource_params
end
# Source: https://gist.github.com/kazpsp/3350730
