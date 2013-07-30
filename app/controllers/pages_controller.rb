class PagesController < HighVoltage::PagesController
  layout :layout_for_page

  # Redirect signed in users to app when visiting root_path
  def show
    if user_signed_in? && current_path == root_path
      return redirect_to current_user.first_project_path
    end

    super
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
end
