# Heroku from the command line
#
# # Steps
# 1) Install heroku toolbelt with brew
# $ brew install heroku-toolbelt
# (See github.com/thoughtbot/laptop)
#
# 2) Add deployment scripts to /usr/local/bin
# From github.com/thoughtbot/dotfiles
#
# 3) Marvel at your new bash commands
# production backup
# production console
# production migrate
# production tail
#
# production open
# watch production ps
#
# The script also acts as a pass-through, so you can do anything with it
# that you can do with `heroku __________ -r production`.
#
# Deployment is automated with `rake production:deploy`,
# which also pushes the master branch to Github.

# Production app
namespace :production do
  desc 'Deploy to PRODUCTION'
  task :deploy do
    puts    'Pushing to Github...'
    system  'git push origin master'
    puts    'Pushed to Github'

    puts    'Deploying to production...'
    system  'git push production master'
    puts    'Deployed to production'
  end
end

# Staging app
namespace :staging do
  desc 'Deploy to STAGING'
  task :deploy do
    puts    'Pushing to development branch on Github...'
    system  'git push origin develop'
    puts    'Pushed to Github'

    puts    'Deploying to staging...'
    system  'git push staging develop:master'
    puts    'Deployed to staging'
  end
end
