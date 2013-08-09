class PublicStatusController < ApplicationController
  def show
    @status = Status.find_by!(token: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url, alert: "Status could not be found."
  end
end
