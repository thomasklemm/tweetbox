class PagesController < HighVoltage::PagesController
  layout :layout_for_page

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
