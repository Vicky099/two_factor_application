require 'authy'
require 'twilio-ruby'
require "uri"
require 'net/http'

class AuthyService

	def initialize(user)
		@user = user
		@two_factor = @user.get_two_factor_method
	end

	def register_user
		authy_response = Authy::API.register_user(:email => @user.email, :cellphone => @user.mob_no, :country_code => @user.country_code)
		response = AuthyResponseService.new(authy_response)
		if response.ok?
			@two_factor.update(service_id: response.id.to_s)
		else
			puts response.errors
		end
	end

	def send_token
		if @user.email?
			# API not working so developed using custom method
			# authy_response = Authy::API.request_email(:id => @two_factor.service_id, :force => true)
			authy_response = request_email_custom(:id => @two_factor.service_id, :force => true)
		elsif @user.voice?
			authy_response = Authy::API.request_phone_call(:id => @two_factor.service_id, :force => true)			
		else
			authy_response = Authy::API.request_sms(:id => @two_factor.service_id, :force => @user.sms?)
		end
		response = AuthyResponseService.new(authy_response)
		if response.success?
			return 'success', 'We have sent a token on your registered channel. Please verify it.'
		else
			return 'error', response.error_message
		end
	end

	def verify_user(token)
		authy_response = Authy::API.verify(:id => @two_factor.service_id, :token => token)
		response = AuthyResponseService.new(authy_response)
		if response.ok?
			@user.update(sign_in_status: 'approved')
			return 'success', 'Verification successful'
		else
			puts response.errors
			return 'error', 'Please try again'
		end
	end

	def send_email_by_curl
		uri = URI.parse("https://api.authy.com/protected/json/email/#{@two_factor.service_id}")
		http = Net::HTTP.new(uri.host)
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = URI.encode_www_form({:force => true})
		request.add_field("X-Authy-API-Key", Authy.api_key)
		response = Net::HTTP.start(uri.hostname, uri.port, {use_ssl: uri.scheme == "https"}) do |http|
		  	http.request(request)
		end
		return JSON.parse(response.body)
	end

	def request_email_custom(params)
		user_id = params.delete(:id) || params.delete('id')
		Authy::API.post_request("protected/json/email/:user_id", params.merge({"user_id" => user_id}))
	end

end