class InvitationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def name
    "#{first_name} #{last_name}"
  end

  def issuer_name
    issuer.name
  end

  def issuer_email
    issuer.email
  end

  def active_until
    expires_at.utc.to_s(:long)
  end

  def registration_url
    new_registration_url(invitation_token: token, email: email, first_name: first_name, last_name: last_name).html_safe
  end

  def copy_registration_url(text)
    link_to icon_tag(:copy, text), 'javascript:;',
      class: 'copy-button', 'data-clipboard-text' => "#{ registration_url }"
  end

  # Gravatar with retro fallback
  def gravatar_image_url(size_in_pixels=32)
    email_hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{ email_hash }?s=#{ size_in_pixels.to_i }&d=retro"
  end
end
