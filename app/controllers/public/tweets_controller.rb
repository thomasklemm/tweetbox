class Public::TweetsController < ApplicationController
  def show
    @tweet = Tweet.where(twitter_id: params[:twitter_id]).first!
    @tweet &&= @tweet.decorate

  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Tweet could not be found.'
  end
end
