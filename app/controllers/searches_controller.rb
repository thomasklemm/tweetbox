class SearchesController < ProjectController
  def index
    @searches = project_searches
  end

  def show
    @search = project_search
  end

  def new
    @search = project_searches.build
  end

  def create
    @search = project_searches.build(search_params)

    if @search.save
      redirect_to project_search_path(@project, @search), notice: 'Search has been created.'
    else
      render :new
    end
  end

  def edit
    @search = project_search
  end

  def update
    @search = project_search

    if @search.update_attributes(search_params)
      redirect_to project_search_path(@project, @search), notice: 'Search has been updated.'
    else
      render :edit
    end
  end

  def destroy
    @search = project_search
    @search.destroy
    redirect_to project_searches_path, notice: "Search '#{ @search.query }' has been destroyed."
  end

  private

  def project_searches
    @project.searches
  end

  def project_search
    project_searches.find(params[:search_id] || user_session[:search_id] || params[:id])
  end

  def search_params
    params.require(:search).permit(:query, :twitter_account_id)
  end
end
