# == Schema Information
#
# Table name: users
#
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  id                     :integer          not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  name                   :string(255)      default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :string(255)
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'spec_helper'

describe User do
  let(:user) { Fabricate.build(:user) }

  describe '#name' do
    it 'is required' do
      expect(user).to validate_presence_of(:name)
    end
  end

  describe '#email' do
    it 'is required' do
      expect(user).to validate_presence_of(:email)
    end

    it 'must be unique' do
      another_user = Fabricate(:user, email: user.email)
      expect(user).to have(1).error_on(:email)
      expect(user).not_to be_valid
    end
  end

  describe '#password' do
    it 'is required' do
      expect(user).to validate_presence_of(:password)
    end
  end
end
