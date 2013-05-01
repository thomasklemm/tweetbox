# Allow Devise to work with strong_parameters
class Users::PasswordsController < Devise::PasswordsController
  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
  private :resource_params
end
# Source: https://gist.github.com/kazpsp/3350730
