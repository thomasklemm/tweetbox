class AccountsController < AccountController
  def show
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

  def team
    render 'shared/team'
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
