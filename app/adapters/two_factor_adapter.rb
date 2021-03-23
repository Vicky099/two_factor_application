module TwoFactorAdapter
	class TwoFactorWrapper
		def initialize(user)
			@user = user
			@tfactor = @user.get_two_factor_method
			@adapter ||=  	case user.two_factor_provider
							when 'authy'
								AuthyService.new(user)
							when 'okta'
								OktaService.new(user)
							end
		end

		def register_user
			@adapter.register_user
		end

		def send_token
			unless @tfactor.service_id.present?
				register_user
			end
			if @tfactor.service_id.present?
				@adapter.send_token
			end
		end

		def verify_user(token)
			@adapter.verify_user(token)
		end

		def enroll_factor
			@adapter.enroll_factor
		end

		def activate_factor(enroll_factor_id, token)
			@adapter.activate_factor(enroll_factor_id, token)
		end
	end
end