class UserDecorator < Draper::Decorator
  delegate_all

  # Link to project if only one is present,
  # else link to all projects
  def project_link
    if projects.size == 1
      h.link_to 'Project', h.project_path(projects.first)
    else
      h.link_to 'Projects', h.projects_path
    end
  end

  # Link to account if only one is present,
  # else link to all accounts
  def account_link
    if accounts.size == 1
      h.link_to 'Account', h.account_path(accounts.first)
    else
      h.link_to 'Accounts', h.accounts_path
    end
  end

  def gravatar_image_url
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "http://www.gravatar.com/avatar/#{ hash }?s=32"
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
