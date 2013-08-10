class PublicStatusesController < ApplicationController
  def show
    @status = Status.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url, alert: "Status could not be found."
  end
end
