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

    it "schedules queries and fetches timelines" do
      # Mentions timeline
      expect(MentionsTimelineWorker).to have(15).jobs

      # User timeline
      expect(UserTimelineWorker).to have(40).jobs

      # fetches up to 100 mentions (mentions_timeline)
      expect(project.tweets.incoming).to have(11).tweets

      # fetches up to 3,200 posted statuses (user_timeline)
      expect(project.tweets.posted).to have(55).tweets

      # sets the imported_at timestamp on the twitter account
      expect(twitter_account.reload.imported_at).to eq(Time.current)
    end

    # it "schedules initial timeline queries" do
    #   # Mentions timeline
    #   expect(MentionsTimelineWorker).to have(15).jobs

    #   # # Up to 20 minutes
    #   # [2, 4, 6, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].each do |n|
    #   #   perform_at = twitter_account.created_at + n.minutes
    #   #   expect(MentionsTimelineWorker).to have_queued_job_at(perform_at, twitter_account.id, perform_at.iso8601)
    #   # end

    #   # User timeline
    #   expect(UserTimelineWorker).to have(40).jobs

    #   # # Up to 20 minutes
    #   # (30..1200).step(30) do |n|
    #   #   perform_at = twitter_account.created_at + n.seconds
    #   #   expect(UserTimelineWorker).to have_queued_job_at(perform_at, twitter_account.id, perform_at.iso8601)
    #   # end
    # end

    # it "fetches up to 100 mentions (mentions_timeline)" do
    #   expect(project.tweets.incoming).to have(11).tweets
    # end

    # it "fetches up to 3,200 posted statuses (user_timeline)" do
    #   expect(project.tweets.posted).to have(55).tweets
    # end

    # it "sets the imported_at timestamp on the twitter account" do
    #   expect(twitter_account.reload.imported_at).to eq(Time.current)
    # end
  end
end
