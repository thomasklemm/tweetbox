RSpec.configure do |config|
  config.before(:each) do
    OmniAuth.config.mock_auth[:twitter] =
      YAML.load(File.read(Rails.root.join("spec", "support", "omniauth", "twitter.yml")))
  end
end
