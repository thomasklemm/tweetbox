class PagesController < HighVoltage::PagesController
  layout :layout_for_page

  # Redirect signed in users to app when visiting root_path
  def show
    if user_signed_in? && current_path == root_path
      return redirect_to main_user_project_path
    end

    super
  end

  def debug
    result = renderer.render(Tweet.first)

    raise result.inspect
  end

  private

  def layout_for_page
    case params[:id]
    # regular expression, you can catch multiple pages
    # with /landing|pricing|features/
    when /landing/
      'marketing'
    else
      'application'
    end
  end

  def renderer
    @renderer ||= Renderer.new.renderer
  end
end



