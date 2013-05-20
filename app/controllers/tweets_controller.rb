class TweetsController < ProjectController
  before_filter :load_project_tweet, except: :index

  def index
    @tweets = case params[:flow].to_s
    when 'incoming' then project_tweets.incoming.limit(20)
    when 'replying' then project_tweets.replying.limit(10)
    when 'resolved' then project_tweets.resolved.limit(10)
    else return redirect_to project_tweets_path(@project, flow: :incoming)
    end
    @tweets &&= @tweets.decorate
  end

  def show
  end

  def mark_as_open
    @tweet.open!

    # Record event
    @tweet.events.create!(user: current_user, event_type: :new_workflow_state, details: { target_state: :open })

    redirect_to project_tweet_path(@project, @tweet)
  end

  def mark_as_closed
    @tweet.close!

    # Record event
    @tweet.events.create!(user: current_user, event_type: :new_workflow_state, details: { target_state: :closed })

    respond_to do |format|
      format.html { redirect_to project_tweet_path(@project, @tweet) }
      format.js
    end
  end
end
