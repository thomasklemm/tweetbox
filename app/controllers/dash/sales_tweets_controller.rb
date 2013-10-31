class Dash::SalesTweetsController < Dash::ApplicationController
  before_action :set_sales_tweet, only: [:show, :edit, :update, :destroy, :publish]

  def index
    @sales_tweets = SalesTweet.all
  end

  def show
    @status = Status.new
  end

  def new
    @sales_tweet = SalesTweet.new
  end

  def edit
  end

  def create
    @sales_tweet = SalesTweet.new(sales_tweet_params)

    if @sales_tweet.save
      redirect_to [:dash, @sales_tweet], notice: 'Sales tweet was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @sales_tweet.update(sales_tweet_params)
      redirect_to [:dash, @sales_tweet], notice: 'Sales tweet was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @sales_tweet.destroy
    redirect_to dash_sales_tweets_url, notice: 'Sales tweet was successfully destroyed.'
  end

  def publish
    username = params[:username]
    @status = Status.new(status_params(@sales_tweet, username))

    if @status.save
      @status.publish!
      redirect_to [:dash, @sales_tweet], notice: "Published sales tweet to @#{ username }. (#{ view_context.link_to('See it.', @status.tweet.try(:decorate).try(:twitter_url).presence || @status.public_url) })".html_safe
    else
      render :show
    end
  end

  private

  def set_sales_tweet
    @sales_tweet = SalesTweet.find(params[:id])
  end

  def sales_tweet_params
    params.require(:sales_tweet).permit(:text, :twitter_text)
  end


  def status_params(sales_tweet, username)
    {
      project: Project.find_by!(use_in_sales_tweets: true),
      twitter_account: TwitterAccount.find_by!(use_in_sales_tweets: true),
      user: current_user,
      text: sales_tweet.render_text_for(username),
      use_twitter_text: true,
      twitter_text: sales_tweet.render_twitter_text_for(username)
    }
  end
end
