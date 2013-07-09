class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  # Gravatar with retro fallback
  def gravatar_image_url(size_in_pixels=28)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{ hash }?s=#{ size_in_pixels.to_i }&d=retro"
  end

  def main_project_path
    if projects.one?
      project_path(projects.first)
    else
    end
  end
end
