class TweetsController < TweetController
  before_filter :load_project_tweet, except: :index
  # respond_to :js, only: [:appreciate, :resolve, :open_case]

  def index
    @tweets = project_tweets.where(workflow_state: [:new, :open, :closed]).limit(20)
    @tweets &&= @tweets.decorate
  end

  def show
  end

  def appreciate
    @tweet.close!
    create_event(:appreciate)
    redirect_to incoming_project_tweets_path(@project), notice: 'Tweet has been appreciated.'
  end

  def resolve
    @tweet.close!
    create_event(:resolve)
    redirect_to incoming_project_tweets_path(@project), notice: 'Case has been resolved.'
  end

  def open_case
    @tweet.open!
    create_event(:open_case)
    redirect_to project_tweet_path(@project, @tweet), notice: 'Case has been opened.'
  end

  # def open_case_and_start_reply
  #   @tweet.open!
  #   create_event(:open_case)
  #   redirect_to new_project_tweet_reply_path(@project, @tweet), notice: 'Reply has been started.'
  # end

  private

  def project_tweets
    @project.tweets
  end

  def create_event(kind)
    @tweet.events.create!(kind: kind, user: current_user)
  end
end
