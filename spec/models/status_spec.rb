# == Schema Information
#
# Table name: statuses
#
#  code               :text             not null
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  posted_at          :datetime
#  posted_text        :text
#  project_id         :integer          not null
#  text               :text             not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_statuses_on_code        (code) UNIQUE
#  index_statuses_on_project_id  (project_id)
#

require 'spec_helper'

describe Status do
  subject(:status) { Fabricate.build(:status) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should belong_to(:user) }
  it { should belong_to(:twitter_account) }

  it { should validate_presence_of(:project) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:twitter_account) }
  it { should validate_presence_of(:text) }

  describe "#posted?" do
    it "is not posted on creation" do
      expect(status).to_not be_posted
    end

    it "is posted when posted_at timestamp is set" do
      status.posted_at = Time.current
      expect(status).to be_posted
    end
  end

  describe "#length" do
    it "returns the length of the tweet as seen by Twitter" do
      status.text = '0123456789'
      expect(status.length).to eq(10)

      status.text = '0123456789 http://google.com 0123456789'
      expect(status.length).to eq(44)

      status.text = '0123456789 https://google.com 0123456789'
      expect(status.length).to eq(45)
    end
  end

  describe "#valid_tweet?" do
    it "returns true for valid tweet bodies" do
      status.posted_text = '0123456789 http://google.com 0123456789'
      expect(status).to be_valid_tweet
    end

    it "returns false for invalid tweet bodies" do
      status.text = ''
      expect(status).to_not be_valid_tweet

      status.text = '0' * 141
      expect(status).to_not be_valid_tweet
    end
  end

  describe "#public_url" do
    it "returns a full url that the status is accessible with" do
      status.save
      expect(status.public_url).to match(/statuses\/\d+/)
    end
  end

  describe "#save" do
    describe "#generate_posted_text", :focus do
      it "sets the text as posted text if it is below 140 characters and would be a valid tweet" do
        status.text = '0' * 20000
        status.save
        puts [status.posted_text, status.length]
      end
    end
  end
end
