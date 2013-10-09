module NavigationHelper
  def active_list_item(url_parts, exact=false)
    content_tag :li, class: ('active' if active_path?(url_parts)) do
      yield
    end
  end

  def list_group_link_to(*args, &block)
    link_to_path = args[0]
    active_path = args[1] || args[0]
    exact_match = args[2]

    link_to(link_to_path, class: "list-group-item #{ 'active' if active_path?(active_path, exact_match) }") do
      block.call
    end
  end

  def active_path?(url_parts, exact=false)
    if exact
      request.fullpath == url_for(url_parts)
    else
      request.fullpath.starts_with?(url_for(url_parts))
    end
  end
end
