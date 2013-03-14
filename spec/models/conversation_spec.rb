# == Schema Information
#
# Table name: conversations
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  project_id :integer
#  updated_at :datetime         not null
#
# Indexes
#
#  index_conversations_on_project_id  (project_id)
#

require 'spec_helper'

describe Conversation do
  subject(:conversation) { Fabricate.build(:conversation) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should validate_presence_of(:project) }

  it { should have_many(:tweets) }
end
