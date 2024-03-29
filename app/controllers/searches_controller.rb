class SearchesController < ProjectController
  before_filter :load_search, only: [:edit, :update, :destroy]

  def index
    @searches = project_searches
  end

  def new
    @search = project_searches.build
  end

  def create
    @search = project_searches.build(search_params)

    if @search.save
      track 'Search Create', @search

      redirect_to project_searches_path(@project),
        notice: "Search for '#{ @search.query }' has been created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    old_query = @search.query
    if @search.update_attributes(search_params)
      track 'Search Update', @search, {
        'Old Query' => old_query,
        'New Query' => @search.query
      }

      redirect_to project_searches_path(@project),
        notice: "Search for '#{ @search.query }' has been updated."
    else
      render :edit
    end
  end

  def destroy
    @search.destroy
    track 'Search Destroy', @search, {
      'Query' => @search.query
    }

    redirect_to project_searches_path,
      notice: "Search for '#{ @search.query }' has been destroyed."
  end

  private

  def project_searches
    @project.searches
  end

  def project_search
    project_searches.find(params[:search_id] || user_session[:search_id] || params[:id])
  end

  def load_search
    @search = project_search
  end

  def search_params
    params.require(:search).permit(:query, :twitter_account_id, :state)
  end
end
