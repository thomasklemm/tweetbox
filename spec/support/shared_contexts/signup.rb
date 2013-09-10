shared_context "signup" do
  let(:signup) do
    signup = Fabricate(:signup, first_name: 'Thomas', last_name: 'Klemm', company_name: 'Rainmakers', email: 'thomas@tweetbox.co', password: '123123123')
    signup.save
    signup
  end

  let(:user) { signup.user }
  let(:account) { signup.account }
  let(:membership) { signup.membership }
  let(:project) { signup.project }
  let(:permission) { signup.permission }
end
