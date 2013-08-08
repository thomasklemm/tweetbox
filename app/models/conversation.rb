# Joins previous and future tweets
class Conversation < ActiveRecord::Base
  belongs_to :previous_tweet,
             class_name: 'Tweet',
             counter_cache: :future_tweets_count

  belongs_to :future_tweet,
             class_name: 'Tweet',
             counter_cache: :previous_tweets_count
end
