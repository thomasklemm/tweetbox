# A request that requires login
#
# Specs for the default Devise behaviour
# when a user or guest is trying to access
# a controller action filtered with
#   before_filter :authenticate_user!
#
shared_examples "a request that requires login" do
  it { should redirect_to(login_path) }
  it { should set_the_flash }
  its(:current_user) { should be_blank }
end
