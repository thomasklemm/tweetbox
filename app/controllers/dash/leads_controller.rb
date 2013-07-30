class Dash::LeadsController < Dash::ApplicationController
  before_action :load_lead, only: [:show, :update, :refresh, :destroy]

  ##
  # Collection actions

  # Search leads on Twitter
  def search
    @search = TwitterUserSearch.new(params[:query], params[:page])
  end

  # Remember leads
  def remember
    load_lead
  end

  # Score leads
  def score
    search

    @leads = Lead.having_score(score_params).
      by_joined_twitter_at.page(params[:page])

    @score_name = case score_params.to_s
                  when 'high'      then 'High Scoring Leads'
                  when 'medium'    then 'Medium Scoring Leads'
                  when 'secondary' then 'Secondary Accounts'
                  when 'unscored'  then 'Unscored Leads'
                  end
  end

  ##
  # Member actions

  def show
  end

  def update
    @lead.update(lead_params)
  end

  # Updates the lead and fetches the most recent 200 tweets
  # in the user timeline from Twitter
  def refresh
    @lead.fetch_user
    @lead.fetch_user_timeline(200)

    redirect_to dash_lead_path(@lead),
      notice: "Lead @#{ @lead.screen_name } has been updated from Twitter."
  end

  def destroy
    @lead.destroy
    redirect_to score_dash_leads_path,
      notice: "Lead @#{ @lead.screen_name } has been removed."
  end

  private

  def load_lead
    @lead = Lead.find_or_fetch_by_screen_name(params[:id] || params[:screen_name])
    return redirect_to dash_root_path, alert: "@#{ params[:id] } could not be found on Twitter." unless @lead.present?
  end

  def lead_params
    params.require(:lead).permit(:score)
  end

  # Assigns score unless set, too.
  def score_params
    params[:score] ||= :unscored
  end
end
