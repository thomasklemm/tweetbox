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

require 'spec_helper'

describe Code do
  pending "add some examples to (or delete) #{__FILE__}"
end
