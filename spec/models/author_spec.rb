# == Schema Information
#
# Table name: authors
#
#  created_at        :datetime         not null
#  description       :text
#  followers_count   :integer          default(0)
#  friends_count     :integer          default(0)
#  id                :integer          not null, primary key
#  location          :text
#  name              :text
#  profile_image_url :text
#  project_id        :integer          not null
#  screen_name       :text
#  statuses_count    :integer          default(0)
#  twitter_id        :integer          not null
#  updated_at        :datetime         not null
#  url               :text
#  verified          :boolean          default(FALSE)
#
# Indexes
#
#  index_authors_on_project_id                 (project_id)
#  index_authors_on_project_id_and_twitter_id  (project_id,twitter_id) UNIQUE
#

require 'spec_helper'

# FIXME: OUTDATED!

# describe Author do
#   subject(:author) { Fabricate.build(:author) }
#   it { should be_valid }

#   it { should belong_to(:project) }
#   it { should validate_presence_of(:project) }

#   it { should have_many(:tweets) }

#   let(:project) { Fabricate(:project) }
#   let(:status)  { Fabricate.build(:twitter_status) }

#   describe ".find_or_create_author(project, status)" do
#     subject(:author) { Author.find_or_create_author(project, status) }

#     it "persists the author and returns it" do
#       expect(author).to be_an(Author)
#       expect(author).to be_persisted
#     end

#     it "assigns the author's fields from the status" do
#       expect(author.twitter_id).to eq(status.user.id)
#       expect(author.screen_name).to eq(status.user.screen_name)
#     end
#   end

#   describe "#assign_fields_from_status(status)" do
#     let(:status) { Fabricate.build(:twitter_status) }
#     let(:user) { status.user }

#     before { author.send(:assign_fields_from_status, status) }

#     it "assigns the author's twitter_id" do
#       expect(author.twitter_id).to eq(user.id)
#     end

#     it "assigns the author's name" do
#       expect(author.name).to eq(user.name)
#     end

#     it "assigns the author's screen_name" do
#       expect(author.screen_name).to eq(user.screen_name)
#     end

#     it "assigns the author's location" do
#       expect(author.location).to eq(user.location)
#     end

#     it "assigns the author's description" do
#       expect(author.description).to eq(user.description)
#     end

#     it "assigns the author's url" do
#       expect(author.url).to eq(user.url)
#     end

#     it "assigns the author's verification status" do
#       expect(author.verified).to eq(user.verified)
#     end

#     it "assigns the author's creation datetime" do
#       expect(author.created_at).to eq(user.created_at)
#     end

#     it "assigns the author's followers_count" do
#       expect(author.followers_count).to eq(user.followers_count)
#     end

#     it "assigns the author's friends_count" do
#       expect(author.friends_count).to eq(user.friends_count)
#     end

#     it "assigns the author's profile_image_url" do
#       expect(author.profile_image_url).to eq(user.profile_image_url_https)
#     end
#   end
# end

# describe Author, 'persisted' do
#   subject(:author) { Fabricate(:author) }
#   it { should be_valid }

#   it { should validate_uniqueness_of(:twitter_id).scoped_to(:project_id) }
# end
