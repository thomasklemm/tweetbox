shared_examples "sidekiq options" do
  describe "sidekiq options" do
    let(:sidekiq_options) { subject.class.get_sidekiq_options }

    it "does not retry failing jobs" do
      expect(sidekiq_options['retry']).to eq(false)
    end

    it "uses the default queue" do
      expect(sidekiq_options['queue']).to eq('default')
    end
  end
end
