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

  describe "#code" do
    subject(:status) { Fabricate(:status) }

    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
  end

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
    it "returns the length of the posted text as seen by Twitter" do
      status.posted_text = '0123456789'
      expect(status.length).to eq(10)

      status.posted_text = '0123456789 http://google.com 0123456789'
      expect(status.length).to eq(44)

      status.posted_text = '0123456789 https://google.com 0123456789'
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
    it "returns the full public url of the status" do
      status.valid?
      expect(status.public_url).to match %r{https://tweetbox.com/statuses/\S{8}}
    end
  end

  describe "before_validation callbacks" do
    describe "#generate_code" do
      it "assigns a unique code that is persisted and does not change" do
        status.valid?
        code = status.code
        expect(code).to be_present
        expect(code.length).to eq(8)

        # Code will not change
        status.valid?
        expect(status.code).to eq(code)
      end
    end

    describe "#generate_posted_text" do
      context "text length is less than or equal to 140 characters" do
        it "sets the posted text unchanged" do
          status.text = '0' * 140
          status.valid?
          expect(status.posted_text).to eq(status.text)

          status.posted_text = nil
          status.text = 'https://google.com/123123/123123/123123?123=123&123=123 ' + '0' * 116
          status.valid?
          expect(status.posted_text).to eq(status.text)
        end

        it "does not change an existing posted text" do
          status.text = '0' * 140
          status.valid?
          posted_text = status.posted_text
          expect(posted_text).to eq(status.text)

          status.text = '1' * 140
          status.valid?
          expect(posted_text).to_not eq(status.text)
          expect(status.posted_text).to eq(posted_text)
        end
      end

      context "text length is over 140 characters" do
        it "sets a shortened posted text containing the public url" do
          status.text = '0' * 141
          status.valid?
          expect(status.posted_text).to_not eq(status.text)
          expect(status.posted_text).to eq('0' * 113 + "... #{ status.public_url }")
          expect(status.length).to eq(140)

          status.posted_text = nil
          status.text = 'https://google.com/123123/123123/123123?123=123&123=123 ' + '0' * 117
          status.valid?
          expect(status.posted_text).to_not eq(status.text)
          expect(status.posted_text).to eq('https://google.com/123123/123123/123123?123=123&123=123 ' + '0' * 89 + "... #{ status.public_url }")
          expect(status.length).to eq(140)
        end

        it "handles very long texts in a speedy manner" do
          status.text = '0' * 100_000
          status.valid?
          expect(status.posted_text).to eq('0' * 113 + "... #{ status.public_url }")
          expect(status.length).to eq(140)
        end

        it "does not change an existing posted text" do
          status.text = '0' * 141
          status.valid?
          posted_text = status.posted_text
          expect(posted_text).to eq('0' * 113 + "... #{ status.public_url }")

          status.text = '1' * 141
          status.valid?
          expect(status.posted_text).to eq(posted_text)
        end
      end
    end
  end
end
