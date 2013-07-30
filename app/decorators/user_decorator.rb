class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  # Gravatar with retro fallback
  def gravatar_image_url(size_in_pixels=28)
    email_hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{ email_hash }?s=#{ size_in_pixels.to_i }&d=retro"
  end

  def has_exactly_one_project?
    projects.size == 1
  end

  def first_project_path
    projects.first.present? ? project_path(projects.first) : projects_path
  end
end
