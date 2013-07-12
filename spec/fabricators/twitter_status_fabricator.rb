# Fabricator(:twitter_status, class_name: 'twitter/tweet') do
#   initialize_with do
#     Twitter::Tweet.new(
#       id: rand(28669546014),
#       text: "status' text",
#       created_at: 30.seconds.ago.iso8601,
#       in_reply_to_status_id: nil,
#       in_reply_to_user_id: nil,
#       user: {
#         id: 28669546014,
#         name: "author's name",
#         screen_name: "author's screen_name",
#         location: "author's location",
#         description: "author's description",
#         url: "author's url",
#         verified: true,
#         created_at: 2.years.ago.iso8601,
#         followers_count: 100,
#         friends_count: 1200,
#         profile_image_url_https: "author's profile_image_url"
#       })
#   end
# end
