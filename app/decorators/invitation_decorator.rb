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
end
