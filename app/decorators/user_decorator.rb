class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  # Link to project if only one is present,
  # else link to all projects
  # TODO: Cache projects_count on users
  def project_link
    if projects.size == 1
      link_to 'Project', project_path(projects.first)
    else
      link_to 'Projects', projects_path
    end
  end

  def account_link
    link_to 'Account', account_path
  end

  # Gravatar with retro fallback
  def gravatar_image_url
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "http://www.gravatar.com/avatar/#{ hash }?s=28&d=retro"
  end
end
