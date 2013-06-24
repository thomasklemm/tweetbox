# == Schema Information
#
# Table name: codes
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  tweet_id   :integer
#  updated_at :datetime         not null
#
# Indexes
#
#  index_codes_on_tweet_id  (tweet_id)
#

class Code < ActiveRecord::Base
  belongs_to :tweet
end
