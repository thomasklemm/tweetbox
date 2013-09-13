class EventDecorator < Draper::Decorator
  delegate_all

  # Links to the eventable if possible
  # else displays the pure eventable name
  def render_eventable
  	helpers.link_to eventable.to_s, [:dash, eventable]
  rescue
  	eventable.to_s
  end
end
