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

ActiveRecord::Schema.define(:version => 20130312161222) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "plan_id"
    t.datetime "trial_expires_at"
  end

  add_index "accounts", ["plan_id"], :name => "index_accounts_on_plan_id"
  add_index "accounts", ["trial_expires_at"], :name => "index_accounts_on_trial_expires_at"

  create_table "invitations", :force => true do |t|
    t.string   "code"
    t.string   "email"
    t.integer  "account_id"
    t.integer  "sender_id"
    t.boolean  "admin",      :default => false, :null => false
    t.boolean  "used",       :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "invitations", ["account_id"], :name => "index_invitations_on_account_id"

  create_table "invitations_projects", :force => true do |t|
    t.integer "invitation_id", :null => false
    t.integer "project_id",    :null => false
  end

  add_index "invitations_projects", ["invitation_id", "project_id"], :name => "index_invitations_projects_on_invitation_id_and_project_id", :unique => true

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "account_id"
    t.boolean  "admin",      :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "memberships", ["user_id", "account_id"], :name => "index_memberships_on_user_id_and_account_id", :unique => true

  create_table "permissions", :force => true do |t|
    t.integer  "membership_id"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "permissions", ["membership_id", "project_id"], :name => "index_permissions_on_membership_and_project", :unique => true
  add_index "permissions", ["user_id", "project_id"], :name => "index_permissions_on_user_id_and_project_id"

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.integer  "price",      :default => 0,     :null => false
    t.integer  "user_limit",                    :null => false
    t.boolean  "trial",      :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "projects", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "projects", ["account_id"], :name => "index_projects_on_account_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "twitter_accounts", :force => true do |t|
    t.integer  "project_id"
    t.string   "uid"
    t.string   "token"
    t.string   "token_secret"
    t.integer  "twitter_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.string   "description"
    t.string   "url"
    t.string   "profile_image_url"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "auth_scope"
  end

  add_index "twitter_accounts", ["project_id", "uid"], :name => "index_twitter_accounts_on_project_id_and_uid", :unique => true
  add_index "twitter_accounts", ["project_id"], :name => "index_twitter_accounts_on_project_id"

  create_table "users", :force => true do |t|
    t.string   "name",                   :default => "", :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
