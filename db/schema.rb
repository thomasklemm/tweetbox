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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130918180209) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.text     "name",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "projects_count"
  end

  create_table "authors", force: true do |t|
    t.integer  "project_id",                                  null: false
    t.integer  "twitter_id",        limit: 8,                 null: false
    t.text     "name"
    t.text     "screen_name"
    t.text     "location"
    t.text     "description"
    t.text     "url"
    t.boolean  "verified",                    default: false
    t.integer  "followers_count",             default: 0
    t.integer  "friends_count",               default: 0
    t.text     "profile_image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "statuses_count",              default: 0
    t.datetime "joined_twitter_at"
    t.text     "lang"
    t.text     "time_zone"
  end

  add_index "authors", ["project_id", "twitter_id"], name: "index_authors_on_project_id_and_twitter_id", unique: true, using: :btree
  add_index "authors", ["project_id"], name: "index_authors_on_project_id", using: :btree

  create_table "conversations", force: true do |t|
    t.integer  "previous_tweet_id"
    t.integer  "future_tweet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversations", ["future_tweet_id"], name: "index_conversations_on_future_tweet_id", using: :btree
  add_index "conversations", ["previous_tweet_id", "future_tweet_id"], name: "index_conversations_on_previous_tweet_id_and_future_tweet_id", unique: true, using: :btree
  add_index "conversations", ["previous_tweet_id"], name: "index_conversations_on_previous_tweet_id", using: :btree

  create_table "events", force: true do |t|
    t.text     "name"
    t.integer  "user_id"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["eventable_id", "eventable_type"], name: "index_events_on_eventable_id_and_eventable_type", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "invitation_projects", force: true do |t|
    t.integer "invitation_id", null: false
    t.integer "project_id",    null: false
  end

  add_index "invitation_projects", ["invitation_id", "project_id"], name: "index_invitation_projects_on_invitation_id_and_project_id", unique: true, using: :btree

  create_table "invitations", force: true do |t|
    t.integer  "account_id", null: false
    t.integer  "issuer_id",  null: false
    t.integer  "invitee_id"
    t.text     "token",      null: false
    t.text     "email"
    t.datetime "used_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "first_name"
    t.text     "last_name"
  end

  add_index "invitations", ["account_id"], name: "index_invitations_on_account_id", using: :btree
  add_index "invitations", ["token"], name: "index_invitations_on_token", unique: true, using: :btree

  create_table "lead_tweets", force: true do |t|
    t.integer  "twitter_id",            limit: 8
    t.text     "text"
    t.integer  "in_reply_to_user_id",   limit: 8
    t.integer  "in_reply_to_status_id", limit: 8
    t.text     "source"
    t.text     "lang"
    t.integer  "favorite_count",                  default: 0
    t.integer  "retweet_count",                   default: 0
    t.integer  "lead_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lead_tweets", ["lead_id"], name: "index_lead_tweets_on_lead_id", using: :btree
  add_index "lead_tweets", ["twitter_id"], name: "index_lead_tweets_on_twitter_id", unique: true, using: :btree

  create_table "leads", force: true do |t|
    t.integer  "twitter_id",        limit: 8
    t.text     "screen_name"
    t.text     "name"
    t.text     "description"
    t.text     "location"
    t.text     "profile_image_url"
    t.text     "url"
    t.integer  "followers_count",             default: 0
    t.integer  "statuses_count",              default: 0
    t.integer  "friends_count",               default: 0
    t.datetime "joined_twitter_at"
    t.text     "lang"
    t.text     "time_zone"
    t.boolean  "verified"
    t.boolean  "following"
    t.text     "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leads", ["followers_count"], name: "index_leads_on_followers_count", using: :btree
  add_index "leads", ["score"], name: "index_leads_on_score", using: :btree
  add_index "leads", ["screen_name"], name: "index_leads_on_screen_name", using: :btree
  add_index "leads", ["twitter_id"], name: "index_leads_on_twitter_id", unique: true, using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id",                    null: false
    t.integer  "account_id",                 null: false
    t.boolean  "admin",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["user_id", "account_id"], name: "index_memberships_on_user_id_and_account_id", unique: true, using: :btree

  create_table "permissions", force: true do |t|
    t.integer  "project_id",    null: false
    t.integer  "membership_id", null: false
    t.integer  "user_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["membership_id", "project_id"], name: "index_permissions_on_membership_and_project", unique: true, using: :btree
  add_index "permissions", ["user_id", "project_id"], name: "index_permissions_on_user_id_and_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.integer  "account_id",                             null: false
    t.text     "name",                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_twitter_account_id"
    t.integer  "tweets_count",               default: 0, null: false
    t.integer  "incoming_tweets_count",      default: 0, null: false
    t.integer  "resolved_tweets_count",      default: 0, null: false
    t.integer  "posted_tweets_count",        default: 0, null: false
  end

  add_index "projects", ["account_id"], name: "index_projects_on_account_id", using: :btree

  create_table "searches", force: true do |t|
    t.integer  "twitter_account_id",                          null: false
    t.integer  "project_id",                                  null: false
    t.text     "query",                                       null: false
    t.boolean  "active",                       default: true
    t.integer  "max_twitter_id",     limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["project_id", "twitter_account_id"], name: "index_searches_on_project_id_and_twitter_account_id", using: :btree
  add_index "searches", ["project_id"], name: "index_searches_on_project_id", using: :btree
  add_index "searches", ["twitter_account_id"], name: "index_searches_on_twitter_account_id", using: :btree

  create_table "statuses", force: true do |t|
    t.text     "token"
    t.text     "text"
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "twitter_account_id"
    t.integer  "in_reply_to_status_id", limit: 8
    t.integer  "twitter_id",            limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["project_id"], name: "index_statuses_on_project_id", using: :btree
  add_index "statuses", ["token"], name: "index_statuses_on_token", unique: true, using: :btree
  add_index "statuses", ["twitter_id"], name: "index_statuses_on_twitter_id", using: :btree

  create_table "tweets", force: true do |t|
    t.integer  "project_id",                                      null: false
    t.integer  "twitter_account_id"
    t.integer  "author_id",                                       null: false
    t.integer  "twitter_id",            limit: 8,                 null: false
    t.text     "text"
    t.integer  "in_reply_to_status_id", limit: 8
    t.integer  "in_reply_to_user_id",   limit: 8
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "source"
    t.text     "lang"
    t.integer  "retweet_count",                   default: 0
    t.integer  "favorite_count",                  default: 0
    t.integer  "previous_tweets_count",           default: 0
    t.integer  "future_tweets_count",             default: 0
    t.integer  "status_id"
    t.datetime "resolved_at"
    t.boolean  "replied_to",                      default: false
    t.boolean  "pushed",                          default: false
  end

  add_index "tweets", ["project_id", "author_id"], name: "index_tweets_on_project_id_and_author_id", using: :btree
  add_index "tweets", ["project_id", "state"], name: "index_tweets_on_project_id_and_state", using: :btree
  add_index "tweets", ["project_id", "twitter_id"], name: "index_tweets_on_project_id_and_twitter_id", unique: true, using: :btree
  add_index "tweets", ["project_id"], name: "index_tweets_on_project_id", using: :btree
  add_index "tweets", ["status_id"], name: "index_tweets_on_status_id", using: :btree

  create_table "twitter_accounts", force: true do |t|
    t.integer  "project_id",                                        null: false
    t.text     "uid",                                               null: false
    t.text     "token",                                             null: false
    t.text     "token_secret",                                      null: false
    t.integer  "twitter_id",                              limit: 8, null: false
    t.text     "name"
    t.text     "screen_name"
    t.text     "location"
    t.text     "description"
    t.text     "url"
    t.text     "profile_image_url"
    t.text     "access_scope"
    t.integer  "max_mentions_timeline_twitter_id",        limit: 8
    t.integer  "max_user_timeline_twitter_id",            limit: 8
    t.integer  "max_direct_messages_sent_twitter_id",     limit: 8
    t.integer  "max_direct_messages_received_twitter_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "imported_at"
  end

  add_index "twitter_accounts", ["project_id", "access_scope"], name: "index_twitter_accounts_on_project_id_and_access_scope", using: :btree
  add_index "twitter_accounts", ["project_id", "twitter_id"], name: "index_twitter_accounts_on_project_id_and_twitter_id", using: :btree
  add_index "twitter_accounts", ["project_id"], name: "index_twitter_accounts_on_project_id", using: :btree
  add_index "twitter_accounts", ["twitter_id"], name: "index_twitter_accounts_on_twitter_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.text     "email",                  default: "",    null: false
    t.text     "encrypted_password",     default: "",    null: false
    t.text     "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "staff_member",           default: false
    t.integer  "projects_count"
    t.text     "first_name"
    t.text     "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
