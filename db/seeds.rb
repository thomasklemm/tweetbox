##
# Signup

signup = Signup.new({
  name: 'Thomas Klemm',
  company_name: 'Tweetbox',
  email: 'thomas@tweetbox.co',
  password: '123123123'
})

puts "Signup save: #{ signup.save }"

user    = signup.user
account = signup.account
project = signup.project


##
# Twitter account

auth_hash = YAML.load(File.read(Rails.root.join("spec", "support", "omniauth", "twitter.yml")))
twitter_account = TwitterAccount.from_omniauth(project, auth_hash, 'write')

puts "TwitterAccount persisted: #{ twitter_account.persisted? }"
