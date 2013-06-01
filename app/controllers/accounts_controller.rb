class AccountsController < AccountController
  def show
    # Redirect to first interesting resource
    redirect_to account_projects_path
  end

  def edit
  end

  def update
    if @account.update_attributes(account_params)
      redirect_to account_path, notice: 'Account has been updated.'
    else
      render :edit
    end
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
