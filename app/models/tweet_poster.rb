# class Status
#   include Reformer

#   attribute :text, String
#   validates :text, presence: true

#   attribute :project, Project
#   attribute :user, User
#   attribute :twitter_account, TwitterAccount
#   validates :project, :user, :twitter_account, presence: true

#   attribute :in_reply_to_status_id
#   attribute :in_reply_to_user_id
# end

# class TweetPoster
#   def initialize(status)
#     @status = status
#   end

#   def save
#     generate_posted_text
#   end
# end


# class FacebookCommentNotifier
#   def initialize(comment)
#     @comment = comment
#   end

#   def save
#     @comment.save && post_to_wall
#   end

# private

#   def post_to_wall
#     Facebook.post(title: @comment.title, user: @comment.author)
#   end
# end

# class StatusController
#   def new
#     @status = Status.new(reply_params)
#   end

#   def create
#     @status = TweetPoster.new(Status.new(params[:status]))

#     if @status.save
#       redirect_to project_tweet_path(@project, @status.tweet), notice: "Status has been posted."
#     else
#       render :new
#     end
#   end

#   private

#   def reply_params
#     params.slice(:in_reply_to_status_id, :in_reply_to_user)
#   end
# end
