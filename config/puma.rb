# config/puma.rb
environment ENV['RACK_ENV']
threads 0,5
# workers 3
# source: http://ctshryock.com/posts/2012/07/12/running-rails-with-puma-on-heroku.html
