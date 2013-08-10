# require 'spec_helper'

# describe Status do
#   subject(:status) { Fabricate.build(:status) } # form object
#   before { status.send(:generate_posted_text) }
#   it { should be_valid }

#   it { should validate_presence_of(:project) }
#   it { should validate_presence_of(:user) }
#   it { should validate_presence_of(:twitter_account) }
#   it { should validate_presence_of(:full_text) }
#   it { should validate_presence_of(:posted_text) }

#   it "finds a twitter account based on its id" do
#     twitter_account = Fabricate(:twitter_account, project: status.project)
#     status.twitter_account = nil
#     status.twitter_account_id = twitter_account
#     expect(status.twitter_account).to eq(twitter_account)
#   end
# end

# describe Status, 'posted' do
#   let(:project) { Fabricate(:project) }
#   let(:twitter_account) { Fabricate(:twitter_account, uid: '1444843380', token: '1444843380-hjlU4nf074S6iGPEX153T27FJdnqwisY2HgiHKR', token_secret: 'vpm0nXOzlhnc2BIQJdkUXAsVmsBmzOdPOqQ7pAPzbcg', twitter_id: 1444843380, project: project) }
#   subject(:status) { Fabricate.build(:status, twitter_account: twitter_account, project: project, full_text: "Here’s to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They’re not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them. About the only thing you can’t do is ignore them. Because they change things. They push the human race forward. And while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do.", posted_text: nil) } # form object

#   describe "#save" do
#     before do
#       VCR.use_cassette('statuses/think_different') do
#         @result = status.save
#       end
#     end

#     let(:short_text) { "Here’s to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones... http://lvh.me:7000/t/" }

#     it "returns true" do
#       expect(@result).to be_true
#     end

#     it "generates a posted text with a short url" do
#       expect(status.posted_text).to eq(short_text + status.code.to_param.to_s)
#     end

#     it "persists the posted tweet in the database" do
#       expect(status.posted_tweet).to be_persisted
#     end

#     it "saves the full text with the posted tweet" do
#       expect(status.posted_tweet.text).to eq(short_text + '1') # Replays VCR response
#       expect(status.posted_tweet.full_text).to eq(status.full_text)
#     end
#   end
# end

# #   describe "#length" do
# #     it "returns the length of the posted text as seen by Twitter" do
# #       status.posted_text = '0123456789'
# #       expect(status.length).to eq(10)

# #       status.posted_text = '0123456789 http://google.com 0123456789'
# #       expect(status.length).to eq(44)

# #       status.posted_text = '0123456789 https://google.com 0123456789'
# #       expect(status.length).to eq(45)
# #     end
# #   end

# #   describe "#valid_tweet?" do
# #     it "returns true for valid tweet bodies" do
# #       status.posted_text = '0123456789 http://google.com 0123456789'
# #       expect(status).to be_valid_tweet
# #     end

# #     it "returns false for invalid tweet bodies" do
# #       status.text = ''
# #       expect(status).to_not be_valid_tweet

# #       status.text = '0' * 141
# #       expect(status).to_not be_valid_tweet
# #     end
# #   end

# #   describe "#public_url" do
# #     it "returns the full public url of the status" do
# #       status.valid?
# #       expect(status.public_url).to match %r{https://tweetbox.com/statuses/\S{8}}
# #     end
# #   end

# #   describe "before_validation callbacks" do
# #     describe "#generate_code" do
# #       it "assigns a unique code that is persisted and does not change" do
# #         status.valid?
# #         code = status.code
# #         expect(code).to be_present
# #         expect(code.length).to eq(8)

# #         # Code will not change
# #         status.valid?
# #         expect(status.code).to eq(code)
# #       end
# #     end

# #     describe "#generate_posted_text" do
# #       context "text length is less than or equal to 140 characters" do
# #         it "sets the posted text unchanged" do
# #           status.text = '0' * 140
# #           status.valid?
# #           expect(status.posted_text).to eq(status.text)

# #           status.posted_text = nil
# #           status.text = 'https://google.com/123123/123123/123123?123=123&123=123 ' + '0' * 116
# #           status.valid?
# #           expect(status.posted_text).to eq(status.text)
# #         end

# #         it "does not change an existing posted text" do
# #           status.text = '0' * 140
# #           status.valid?
# #           posted_text = status.posted_text
# #           expect(posted_text).to eq(status.text)

# #           status.text = '1' * 140
# #           status.valid?
# #           expect(posted_text).to_not eq(status.text)
# #           expect(status.posted_text).to eq(posted_text)
# #         end
# #       end

# #       context "text length is over 140 characters" do
# #         it "sets a shortened posted text containing the public url" do
# #           status.text = '0' * 141
# #           status.valid?
# #           expect(status.posted_text).to_not eq(status.text)
# #           expect(status.posted_text).to eq('0' * 113 + "... #{ status.public_url }")
# #           expect(status.length).to eq(140)

# #           status.posted_text = nil
# #           status.text = 'https://google.com/123123/123123/123123?123=123&123=123 ' + '0' * 117
# #           status.valid?
# #           expect(status.posted_text).to_not eq(status.text)
# #           expect(status.posted_text).to eq('https://google.com/123123/123123/123123?123=123&123=123 ' + '0' * 89 + "... #{ status.public_url }")
# #           expect(status.length).to eq(140)
# #         end

# #         it "handles very long texts in a speedy manner" do
# #           status.text = '0' * 100_000
# #           status.valid?
# #           expect(status.posted_text).to eq('0' * 113 + "... #{ status.public_url }")
# #           expect(status.length).to eq(140)
# #         end

# #         it "does not change an existing posted text" do
# #           status.text = '0' * 141
# #           status.valid?
# #           posted_text = status.posted_text
# #           expect(posted_text).to eq('0' * 113 + "... #{ status.public_url }")

# #           status.text = '1' * 141
# #           status.valid?
# #           expect(status.posted_text).to eq(posted_text)
# #         end
# #       end
# #     end
# #   end
# # end
