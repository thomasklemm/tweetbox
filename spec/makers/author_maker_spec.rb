describe AuthorMaker do
  include_context 'signup and twitter account'

  describe ".from_twitter" do
    it "creates the given author and assigns fields and returns the author" do
      VCR.use_cassette('users/simyo') do
        user = twitter_account.client.user('simyo')
        author = AuthorMaker.from_twitter(user, project: project)

        expect(author).to be_an Author
        expect(author).to be_persisted

        expect(author.twitter_id).to eq(user.id)
        expect(author.screen_name).to eq(user.screen_name)
        expect(author.name).to eq(user.name)
        expect(author.description).to eq("Der offizielle simyo Deutschland Twitter-Account. http://www.simyo.de/de/unternehmen/impressum.html") # expanded url
        expect(author.location).to eq(user.location)
        expect(author.profile_image_url).to eq(user.profile_image_url_https)
        expect(author.url).to eq("http://www.simyo.de/") # expanded url
        expect(author.followers_count).to eq(user.followers_count)
        expect(author.statuses_count).to eq(user.statuses_count)
        expect(author.friends_count).to eq(user.friends_count)
        expect(author.joined_twitter_at).to eq(user.created_at)
        expect(author.lang).to eq(user.lang)
        expect(author.time_zone).to eq(user.time_zone)
        expect(author.verified).to eq(user.verified)

        expect{ AuthorMaker.from_twitter(user, project: project) }.to_not raise_error
      end
    end
  end
end
