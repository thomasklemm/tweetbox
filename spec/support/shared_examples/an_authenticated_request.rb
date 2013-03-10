# An authenticated controller action
# Aan action that requires login
#
# Specs for the default Devise behaviour
# when a user or guest is trying to access
# a controller action filtered with
#   before_filter :authenticate_user!
#
shared_examples "an authenticated controller action" do
  it { should redirect_to(login_path) }
  it { should set_the_flash.to("You need to sign in or sign up before continuing.") }
end
