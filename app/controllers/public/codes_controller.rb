class Public::CodesController < ApplicationController
  def redirect
    @code = Code.find(params[:code_id])
    redirect_to public_tweet_path(@code.tweet.author.screen_name, @code.tweet)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Reply code could not be found.'
  end
end
