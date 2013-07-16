# Creates and returns author records
class AuthorMaker
  # Returns the persisted author record
  def self.from_twitter(user, opts={})
    project = opts.fetch(:project) { raise 'Requires a :project' }

    # Find or initialize author
    author = project.authors.where(twitter_id: user.id).first_or_initialize

    # Assign fields
    author.assign_fields(user)

    # Persist author in the database
    # Return author
    author.save! and author

  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
