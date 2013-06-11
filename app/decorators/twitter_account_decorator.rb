class TwitterAccountDecorator < Draper::Decorator
  delegate_all

  def user_intent_url
    "https://twitter.com/intent/user?screen_name=#{ screen_name }"
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
