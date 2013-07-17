require 'spec_helper'

describe Scheduler do
  include_context 'signup and twitter account'

  # Freeze time
  around(:each) do |example|
    Timecop.freeze
    example.run
    Timecop.return

    # Clear job queues
    MentionsTimelineWorker.jobs.clear
    UserTimelineWorker.jobs.clear
  end

  describe ".perform" do
    context "twitter account has been created more than 20 minutes ago" do
      it "schedules timeline queries" do
        # Assume that twitter account has been created more than 20 minutes ago
        twitter_account.update_column(:created_at, 30.minutes.ago)

        Scheduler.perform

        ##
        # Mentions timeline
        expect(MentionsTimelineWorker).to have(10).jobs

        # Schedules one job each minute for the next 10 minutes
        expect(MentionsTimelineWorker).to have_queued_job(twitter_account.id, Time.current.iso8601)

        (1..9).each do |n|
          perform_at = n.minutes.from_now
          expect(MentionsTimelineWorker).to have_queued_job_at(perform_at, twitter_account.id, perform_at.iso8601)
        end

        ##
        # User timeline
        expect(UserTimelineWorker).to have(20).jobs

        # Schedules one job each minute for the next 10 minutes
        expect(UserTimelineWorker).to have_queued_job(twitter_account.id, Time.current.iso8601)

        (30..570).step(30) do |n|
          perform_at = n.seconds.from_now
          expect(UserTimelineWorker).to have_queued_job_at(perform_at, twitter_account.id, perform_at.iso8601)
        end
      end

      it "schedules search queries" do
        search = Fabricate(:search, twitter_account: twitter_account)

        Scheduler.perform

        ##
        # Search
        expect(SearchWorker).to have(10).jobs

        # Schedules one job each minute for the next 10 minutes
        expect(SearchWorker).to have_queued_job(search.id, Time.current.iso8601)

        (1..9).each do |n|
          perform_at = n.minutes.from_now
          expect(SearchWorker).to have_queued_job_at(perform_at, search.id, perform_at.iso8601)
        end
      end
    end
  end
end
