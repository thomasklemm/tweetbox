class PagesController < HighVoltage::PagesController
  # layout :layout_for_page

  def show
    # if user_signed_in? && request.fullpath == root_path
    #   return redirect_to main_user_project_path if current_user.projects.any?
    # end

    super
  end

  private

  # def layout_for_page
  #   case params[:id]
  #   # regular expression, you can catch multiple pages
  #   # with /landing|pricing|features/
  #   when /landing/
  #     'marketing'
  #   else
  #     'application'
  #   end
  # end
end



