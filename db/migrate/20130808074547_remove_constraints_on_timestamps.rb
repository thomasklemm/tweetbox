class RemoveConstraintsOnTimestamps < ActiveRecord::Migration
  def change
    change_column_null :accounts, :created_at, true
    change_column_null :accounts, :updated_at, true

    change_column_null :activities, :created_at, true
    change_column_null :activities, :updated_at, true

    change_column_null :authors, :created_at, true
    change_column_null :authors, :updated_at, true

    change_column_null :codes, :created_at, true
    change_column_null :codes, :updated_at, true

    change_column_null :conversations, :created_at, true
    change_column_null :conversations, :updated_at, true

    change_column_null :events, :created_at, true
    change_column_null :events, :updated_at, true

    change_column_null :invitations, :created_at, true
    change_column_null :invitations, :updated_at, true

    change_column_null :lead_tweets, :created_at, true
    change_column_null :lead_tweets, :updated_at, true

    change_column_null :leads, :created_at, true
    change_column_null :leads, :updated_at, true

    change_column_null :memberships, :created_at, true
    change_column_null :memberships, :updated_at, true

    change_column_null :permissions, :created_at, true
    change_column_null :permissions, :updated_at, true

    change_column_null :projects, :created_at, true
    change_column_null :projects, :updated_at, true

    change_column_null :searches, :created_at, true
    change_column_null :searches, :updated_at, true

    change_column_null :tweets, :created_at, true
    change_column_null :tweets, :updated_at, true

    change_column_null :twitter_accounts, :created_at, true
    change_column_null :twitter_accounts, :updated_at, true

    change_column_null :users, :created_at, true
    change_column_null :users, :updated_at, true
  end
end
