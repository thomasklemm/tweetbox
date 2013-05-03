# == Schema Information
#
# Table name: searches
#
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  project_id         :integer
#  term               :text
#  twitter_account_id :integer
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_searches_on_project_id          (project_id)
#  index_searches_on_twitter_account_id  (twitter_account_id)
#

Fabricator(:search) do
  twitter_account
  term            "term"
end
