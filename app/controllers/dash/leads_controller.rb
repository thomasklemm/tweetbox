class Dash::LeadsController < Dash::ApplicationController
  before_action :load_lead, only: [:show, :update, :refresh, :destroy]

  ##
  # Collection actions

  # Search leads on Twitter
  def search
    build_search
  end

  # Remember leads
  def remember
    load_lead
  end

  # Score leads
  def score
    @leads = Lead.having_score(score_params).
      by_joined_twitter_at.page(params[:page])

    build_search
  end

  ##
  # Member actions

  def show
  end

  def update
    @lead.update(lead_params)
  end

  # Updates the lead and fetches the most recent 100 tweets
  # in the user timeline from Twitter
  def refresh
    @lead.fetch_user
    @lead.fetch_user_timeline

    redirect_to dash_lead_path(@lead),
      notice: "Lead @#{ @lead.screen_name } has been updated from Twitter."
  end

  def destroy
    @lead.destroy
    redirect_to unscored_dash_leads_path,
      notice: "Lead @#{ @lead.screen_name } has been removed."
  end

  private

  def load_lead
    @lead = Lead.find_or_fetch_by screen_name: (params[:id] || params[:screen_name])
    return redirect_to dash_root_path, alert: "@#{ params[:id] } could not be found on Twitter." unless @lead.present?
  end

  def build_search
    @search ||= TwitterUserSearch.new(params[:query], params[:page])
  end

  def lead_params
    params.require(:lead).permit(:score)
  end

  # Assigns score unless set, too.
  def score_params
    params[:score] ||= :unscored
  end
end
