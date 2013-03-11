# A forbidden request
#
# Pundit raises Pundit::NotAuthorized error
# ApplicationController rescues exception
#
shared_examples_for "a forbidden request" do
  def require_message
    raise "Instruction: Requires let(:forbidden_request) { get :forbidden_action, ... } to perform this example."
  end

  before do
    request.env["HTTP_REFERER"] = 'where_user_came_from' # redirect_to :back
    defined?(forbidden_request) ? forbidden_request : require_message # perform or raise instruction error
  end

  it { should redirect_to('where_user_came_from') }

  it 'sets a not authorized error flash message' do
    expect(flash[:error]).to match(/not authorized/)
  end
end
