class ProjectController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_project
  after_filter  :verify_authorized

  layout 'project'

  private

  def load_and_authorize_project
    @project ||= user_project
    authorize @project, :show?
  end

  def project_tweets
    @project.tweets
  end

  def project_tweet
    project_tweets.where(twitter_id: params[:tweet_id] || user_session[:tweet_id] || params[:id]).first!
  end

  def load_project_tweet
    @tweet = project_tweet.decorate
  end
end
