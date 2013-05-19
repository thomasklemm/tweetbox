# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130519204315) do

  create_table "accounts", :force => true do |t|
    t.text     "name",             :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "plan_id"
    t.datetime "trial_expires_at"
  end

  add_index "accounts", ["plan_id"], :name => "index_accounts_on_plan_id"
  add_index "accounts", ["trial_expires_at"], :name => "index_accounts_on_trial_expires_at"

  create_table "authors", :force => true do |t|
    t.integer  "project_id",                                        :null => false
    t.integer  "twitter_id",        :limit => 8,                    :null => false
    t.text     "name"
    t.text     "screen_name"
    t.text     "location"
    t.text     "description"
    t.text     "url"
    t.boolean  "verified",                       :default => false
    t.integer  "followers_count",                :default => 0
    t.integer  "friends_count",                  :default => 0
    t.text     "profile_image_url"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "authors", ["project_id", "twitter_id"], :name => "index_authors_on_project_id_and_twitter_id", :unique => true
  add_index "authors", ["project_id"], :name => "index_authors_on_project_id"

  create_table "comments", :force => true do |t|
    t.integer  "project_id", :null => false
    t.integer  "tweet_id",   :null => false
    t.integer  "user_id",    :null => false
    t.text     "text",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["project_id", "tweet_id"], :name => "index_comments_on_project_id_and_tweet_id"

  create_table "events", :force => true do |t|
    t.integer  "project_id",   :null => false
    t.integer  "tweet_id",     :null => false
    t.integer  "user_id",      :null => false
    t.text     "target_state", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "events", ["project_id", "tweet_id"], :name => "index_events_on_project_id_and_tweet_id"

  create_table "invitations", :force => true do |t|
    t.integer  "account_id",                    :null => false
    t.integer  "sender_id",                     :null => false
    t.integer  "invitee_id"
    t.text     "code",                          :null => false
    t.text     "email",                         :null => false
    t.boolean  "admin",      :default => false
    t.boolean  "used",       :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "invitations", ["account_id"], :name => "index_invitations_on_account_id"
  add_index "invitations", ["code"], :name => "index_invitations_on_code", :unique => true

  create_table "invitations_projects", :force => true do |t|
    t.integer "invitation_id", :null => false
    t.integer "project_id",    :null => false
  end

  add_index "invitations_projects", ["invitation_id", "project_id"], :name => "index_invitations_projects_on_invitation_id_and_project_id", :unique => true

  create_table "memberships", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "account_id",                    :null => false
    t.boolean  "admin",      :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "memberships", ["user_id", "account_id"], :name => "index_memberships_on_user_id_and_account_id", :unique => true

  create_table "permissions", :force => true do |t|
    t.integer  "project_id",    :null => false
    t.integer  "membership_id", :null => false
    t.integer  "user_id",       :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "permissions", ["membership_id", "project_id"], :name => "index_permissions_on_membership_and_project", :unique => true
  add_index "permissions", ["user_id", "project_id"], :name => "index_permissions_on_user_id_and_project_id"

  create_table "plans", :force => true do |t|
    t.text     "name",                          :null => false
    t.integer  "price",      :default => 0,     :null => false
    t.integer  "user_limit",                    :null => false
    t.boolean  "trial",      :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "projects", :force => true do |t|
    t.integer  "account_id", :null => false
    t.text     "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "projects", ["account_id"], :name => "index_projects_on_account_id"

  create_table "replies", :force => true do |t|
    t.integer  "project_id",         :null => false
    t.integer  "tweet_id",           :null => false
    t.integer  "user_id",            :null => false
    t.integer  "twitter_account_id", :null => false
    t.text     "text",               :null => false
    t.datetime "posted_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "replies", ["project_id", "tweet_id"], :name => "index_replies_on_project_id_and_tweet_id"

  create_table "searches", :force => true do |t|
    t.integer  "twitter_account_id",                                :null => false
    t.integer  "project_id",                                        :null => false
    t.text     "query",                                             :null => false
    t.boolean  "active",                          :default => true
    t.integer  "max_tweet_id",       :limit => 8
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "searches", ["project_id", "twitter_account_id"], :name => "index_searches_on_project_id_and_twitter_account_id"
  add_index "searches", ["project_id"], :name => "index_searches_on_project_id"
  add_index "searches", ["twitter_account_id"], :name => "index_searches_on_twitter_account_id"

  create_table "tweets", :force => true do |t|
    t.integer  "project_id",                                        :null => false
    t.integer  "twitter_account_id",                                :null => false
    t.integer  "author_id",                                         :null => false
    t.integer  "twitter_id",            :limit => 8,                :null => false
    t.text     "text"
    t.integer  "in_reply_to_status_id", :limit => 8
    t.integer  "in_reply_to_user_id",   :limit => 8
    t.text     "workflow_state",                                    :null => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "previous_tweet_ids",    :limit => 8,                                :array => true
    t.integer  "replies_count",                      :default => 0
    t.integer  "comments_count",                     :default => 0
    t.integer  "events_count",                       :default => 0
  end

  add_index "tweets", ["previous_tweet_ids"], :name => "index_tweets_on_previous_tweet_ids", :using => :gin
  add_index "tweets", ["project_id", "author_id"], :name => "index_tweets_on_project_id_and_author_id"
  add_index "tweets", ["project_id", "twitter_id"], :name => "index_tweets_on_project_id_and_twitter_id", :unique => true
  add_index "tweets", ["project_id", "workflow_state"], :name => "index_tweets_on_project_id_and_workflow_state"
  add_index "tweets", ["project_id"], :name => "index_tweets_on_project_id"

  create_table "twitter_accounts", :force => true do |t|
    t.integer  "project_id",                                           :null => false
    t.text     "uid",                                                  :null => false
    t.text     "token",                                                :null => false
    t.text     "token_secret",                                         :null => false
    t.integer  "twitter_id",            :limit => 8,                   :null => false
    t.text     "name"
    t.text     "screen_name"
    t.text     "location"
    t.text     "description"
    t.text     "url"
    t.text     "profile_image_url"
    t.text     "authorized_for",                                       :null => false
    t.boolean  "get_mentions",                       :default => true
    t.integer  "max_mentions_tweet_id", :limit => 8
    t.boolean  "get_home",                           :default => true
    t.integer  "max_home_tweet_id",     :limit => 8
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "twitter_accounts", ["project_id", "twitter_id"], :name => "index_twitter_accounts_on_project_id_and_twitter_id"
  add_index "twitter_accounts", ["project_id"], :name => "index_twitter_accounts_on_project_id"
  add_index "twitter_accounts", ["twitter_id"], :name => "index_twitter_accounts_on_twitter_id", :unique => true

  create_table "users", :force => true do |t|
    t.text     "name",                   :default => "", :null => false
    t.text     "email",                  :default => "", :null => false
    t.text     "encrypted_password",     :default => "", :null => false
    t.text     "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.text     "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text     "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
