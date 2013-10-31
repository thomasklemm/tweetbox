class AddUseInSalesTweetsFlagToProjectsAndTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :projects, :use_in_sales_tweets, :boolean, default: false
    add_column :twitter_accounts, :use_in_sales_tweets, :boolean, default: false
  end
end
