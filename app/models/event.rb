class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :eventable, polymorphic: true

  def has_dash_page?
    Rails.application.routes.url_helpers.url_for([:dash, eventable])
  rescue
    false
  end
end
