require "uri"
require 'net/http'

class OktaService

	def initialize(user)
		@user = user
		@two_factor = @user.get_two_factor_method
	end

	# Step 1 create user -> it will create user and return user id
	def register_user
		data, status = Okta.client.create_user(profile: {
					login: @user.email,
					email: @user.email,
					firstName: @user.name.to_s.split(" ")[0],
					lastName: @user.name.to_s.split(" ")[1],
					mobilePhone: "+"+@user.country_code.to_s+@user.mob_no.to_s
				})
		response = OktaResponseService.new(data, status)
		puts data.inspect
		
		if response.success?
			@two_factor.update(service_id: response.id.to_s)
			return 'success', {message: "We have sent you token on your registered channel. Please enter and verify."}
		else
			return 'error', {message: response.error_message}
		end
	end

	# Step 2 - Enroll Factor - pass user id and it will return factor id
	# Here factor type will be sms, push, email, call
	def enroll_factor
		previous_service_factor_id = @two_factor.service_factor_id

		channel = find_channel
		options = {}
		
		if @user.email?
			options = {email: @user.email}
		elsif @user.sms? || @user.voice?
			options = {phoneNumber: "+"+@user.country_code.to_s+@user.mob_no.to_s,}
		end
		
		data, status = Okta.client.enroll_factor(
			@two_factor.service_id,
			{
				factorType: channel,
				provider: "OKTA",
				profile: options
			}
		)
		response = OktaResponseService.new(data, status)
		puts data.inspect
		
		if response.success?
			barcode = @user.app? ? response.barcode : nil
			@two_factor.update(service_factor_id: response.id.to_s, backup_service_factor_id: previous_service_factor_id)
			return 'success', {message: "We have sent you token on your registered channel. Please enter and verify.", id: response.id.to_s, barcode: barcode}
		else
			return 'error', {message: response.error_message}
		end
	end

	# Step 3 - Activate the factor
	def activate_factor(enroll_factor_id, token)
		data, status = Okta.client.activate_factor(
			@two_factor.service_id, 
			enroll_factor_id,
			{
				passCode: token
			}
		)
		response = OktaResponseService.new(data, status)
		puts data.inspect
		
		if response.success?
			@two_factor.update(service_factor_id: response.id.to_s) if response.id.to_s.present?
			reset_factor
			return 'success', {message: "Two Factor channel verified successfully. Please login now."}
		else
			return 'error', {message: response.error_message}
		end
	end

	# Step 4 - Reset factor
	def reset_factor
		data, status = Okta.client.reset_factor(
			@two_factor.service_id, 
			@two_factor.backup_service_factor_id
		)
		response = OktaResponseService.new(data, status)
		
	end

	# Step 1 - Login Send SMS
	def send_token
		push_status = nil
		if @user.app_push?
			data, status = Okta.client.verify_push_factor(
				@two_factor.service_id,
				@two_factor.service_factor_id
			)
			response = OktaResponseService.new(data, status)

			# check status of push
			push_status = check_push_status_in_cycle(data._links[:poll].href, @two_factor.service_id, @two_factor.service_factor_id) if response.success?
		else
			data, status = Okta.client.verify_sms_factor(
				@two_factor.service_id,
				@two_factor.service_factor_id
			)			
			response = OktaResponseService.new(data, status)
		end
	
		puts data.inspect
		
		if response.success?
			if push_status == "TIMEOUT"
				return 'error', {message: 'Timeout occured. Please re-login.', push_status: push_status}
			elsif push_status == "SUCCESS"
				return 'success', {message: 'Your identity verified successfully. Thank you.', push_status: push_status}
			else
				return 'success', {message: 'We have sent a token on your registered channel. Please verify it.'}
			end
		else
			return 'error', {message: response.error_message}
		end
	end

	# Step 2 - Login Verify SMS OTP
	def verify_user(token)
		data, status = Okta.client.verify_sms_factor(
			@two_factor.service_id, 
			@two_factor.service_factor_id, 
			{
				passCode: token
			}
		)
		response = OktaResponseService.new(data, status)
		puts data.inspect
		
		if response.success?
			return 'success', {message: "Your identity verified successfully. Thank you."}
		else
			return 'error', {message: response.error_message}
		end
	end

	def find_channel
		channel = @two_factor.channel
		case channel
		when 'app_push'
			channel = 'push'
		when 'app_token'
			channel = 'token:software:totp'
		when 'voice'
			channel = 'call'
		end
		return channel
	end

	def check_push_status_in_cycle(poll_url, user_id, factor_id)
		transaction_id = URI.parse(poll_url).path.split("/").last

		@status = "WAITING"
		until @status == "SUCCESS"
			data, status = Okta.client.poll_for_verify_transaction_completion(
				@two_factor.service_id,
				@two_factor.service_factor_id,
				transaction_id
			)
			@status = data.factorResult
			puts "status : " + @status
			break if data.factorResult == "TIMEOUT"
			sleep 1
		end
		return @status
	end

end