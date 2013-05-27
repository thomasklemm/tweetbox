class EventDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def render
    case kind
    when 'opened' then render_opened
    # when 'closed' then render_closed
    # when 'posted' then render_posted
    # when 'replied' then render_replied
    # when 'retweeted' then render_retweeted
    # when 'favorited' then render_favorited
    # when 'unfavorited' then render_unfavorited
    else render_unknown
    end
  end

  def user_name
    user.name
  end

  private

  def render_opened
    "#{ icon_tag(:plus) } #{ user_name }: Let's do something.".html_safe
  end

  def render_unknown
    "#{ icon_tag(:'icon-ellipsis-horizontal') } #{ kind.titlecase }: #{ user_name }.".html_safe
  end
end
