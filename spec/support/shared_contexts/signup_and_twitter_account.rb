shared_context "signup and twitter account" do
  include_context "signup"

  let(:auth_hash) { YAML.load(File.read(Rails.root.join("spec", "support", "omniauth", "twitter.yml"))) }
  let(:twitter_account) { TwitterAccount.from_omniauth(project, auth_hash, 'write') }
end
