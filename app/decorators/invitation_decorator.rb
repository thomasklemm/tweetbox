class InvitationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

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
    new_registration_url(invitation_code: code, email: email, name: name).html_safe
  end

  def copy_registration_url(text)
    link_to icon_tag(:copy, text), 'javascript:;',
      class: 'copy-button', 'data-clipboard-text' => "#{ registration_url }"
  end
end
