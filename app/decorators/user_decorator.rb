class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  # Gravatar with retro fallback
  def gravatar_image_url(size_in_pixels=28)
    email_hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{ email_hash }?s=#{ size_in_pixels.to_i }&d=retro"
  end

  # Path the user is redirected to after sign in
  def after_sign_in_path
    projects.size == 1 ? project_path(projects.first) : projects_path
  end
end
