require 'spec_helper'

describe TwitterAccountImportWorker do
  include_context 'signup and twitter account'
  it { should be_a Sidekiq::Worker }

  # Freeze time
  around(:each) do |example|
    Timecop.freeze
    example.run
    Timecop.return

    # Clear job queues
    MentionsTimelineWorker.jobs.clear
    UserTimelineWorker.jobs.clear
  end

  describe "#perform" do
    before do
      VCR.use_cassette('workers/twitter_account_import_worker') do
        TwitterAccountImportWorker.new.perform(twitter_account.id)
      end
    end

    it "fetches timelines" do
      # fetches up to 100 mentions (mentions_timeline)
      expect(project.tweets.incoming).to have(11).tweets

      # fetches up to 3,200 posted statuses (user_timeline)
      expect(project.tweets.posted).to have(55).tweets

      # sets the imported_at timestamp on the twitter account
      expect(twitter_account.reload.imported_at).to eq(Time.current)
    end
  end
end
