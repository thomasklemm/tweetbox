require 'spec_helper'

describe Event do
  subject(:event) { Fabricate(:event) }
  it { should be_valid }

  it { should belong_to(:tweet) }
  it { should belong_to(:user) }
  it { should belong_to(:project) }

  it { should validate_presence_of(:tweet) }
  it { should validate_presence_of(:user) }

  describe "callbacks" do
    before { event.save }

    it "assigns the project from the tweet" do
      expect(event.project).to be_present
      expect(event.project).to eq(event.tweet.project)
    end
  end

  describe "project=" do
    it "raises NotImplementedError" do
      expect{ event.project = nil }.to raise_error(NotImplementedError)
    end
  end

  # Kind
  it { should validate_presence_of(:kind) }
  it { should ensure_inclusion_of(:kind).in_array(Event::VALID_KINDS) }

  describe 'Event::VALID_KINDS' do
    it "describes certain valid kinds of events" do
      expect(Event::VALID_KINDS).to match_array(%w(resolve start_reply post_reply post retweet favorite unfavorite))
    end
  end

  describe "kind=" do
    before { event.kind = nil }

    Event::VALID_KINDS.each do |kind|
      it "accepts '#{ kind.to_s }' string" do
        event.kind = kind.to_s

        expect(event).to be_valid
        expect(event.kind).to eq(kind)
      end

      it "accepts :#{ kind.to_sym } symbol" do
        event.kind = kind.to_sym

        expect(event).to be_valid
        expect(event.kind).to eq(kind)
      end
    end
  end
end
