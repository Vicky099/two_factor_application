class TwoFactorMethod < ApplicationRecord

	belongs_to :user

	validates :name, presence: true, uniqueness: { scope: :user_id}

	enum name: [:authy, :okta, :manual]
	enum status: [:active, :inactive]
	enum channel: [:sms, :app_push, :voice, :email, :app_token]
end
