class User < ApplicationRecord
	
	has_secure_password

	has_many :two_factor_methods, dependent: :destroy

	validates :email, presence: true, uniqueness: true
	validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
	validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

	enum sign_in_status: [:pending, :approved]

	accepts_nested_attributes_for :two_factor_methods


	def get_two_factor_method
		two_factor_methods.active.first
	end
	
	def two_factor_provider
		tfactor = get_two_factor_method
		return tfactor ? tfactor.name : ''
		# two_factor_method.present? ? two_factor_method.name.to_s : ''
	end

	def two_factor_channel
		tfactor = get_two_factor_method
		return tfactor ? tfactor.channel : ''
	end

	def two_factor_registered?
		get_two_factor_method.present?
	end

	def sms?
		tfactor = get_two_factor_method
		return tfactor ? tfactor.sms? : false
	end

	def app_token?
		tfactor = get_two_factor_method
		return tfactor ? tfactor.app_token? : false
	end

	def voice?
		tfactor = get_two_factor_method
		return tfactor ? tfactor.voice? : false
	end

	def email?
		tfactor = get_two_factor_method
		return tfactor ? tfactor.email? : false
	end

	def manual?
		tfactor = get_two_factor_method
		return tfactor ? tfactor.manual? : false
	end

	def app_push?
		tfactor = get_two_factor_method
		return tfactor ? tfactor.app_push? : false
	end

	def app?
		return app_push? || app_token?
	end

	def okta?
		return two_factor_provider == 'okta'
	end
end
