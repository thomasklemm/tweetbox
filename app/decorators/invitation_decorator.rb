class InvitationDecorator < Draper::Decorator
  delegate_all

  def issuer_name
    issuer.name
  end

  def issuer_email
    issuer.email
  end
end
