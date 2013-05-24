class TweetsController < TweetController
  before_filter :load_project_tweet, except: :index

  def index
    @tweets = project_tweets.limit(20)
    @tweets &&= @tweets.decorate
  end

  def show
  end

  def transition
    respond_to do |format|
      case params[:to].to_s
      when 'open'
        @tweet.transition!(to: :open, user: current_user)
        format.html { redirect_to project_tweet_path(@project, @tweet) }
        format.js # renders transition.js.erb template
      when 'closed'
        @tweet.transition!(to: :closed, user: current_user)
        format.html { redirect_to project_tweet_path(@project, @tweet) }
        format.js # renders transition.js.erb template
      else
        format.html { redirect_to :back, alert: 'Valid :to => :open/:closed parameter required.' }
        format.js # renders transition.js.erb template
      end
    end
  end

  private

  def project_tweets
    @project.tweets
  end
end
