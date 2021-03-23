class SessionsController < ApplicationController
	before_action :authenticate!, only: [:logout]
	before_action :check_current_user, only:[:two_factor, :resend_token, :verify_token]
	before_action :check_redirect_if_user_login, only: [:new, :two_factor]

	def new
		# only current user not 2f approved. then reset session
		if current_user && current_user.pending?
			session[:user_id] = nil
		end
	end

	def login
		@user = User.find_by_email(params[:user][:email])
		if @user && @user.authenticate(params[:user][:password])
			session[:user_id] = @user.id
			tfactor = @user.get_two_factor_method
			if tfactor.present? && !tfactor.manual?
				# send token based on channel
				status, response = TwoFactorAdapter::TwoFactorWrapper.new(@user).send_token
				if status == 'success'
					if response[:push_status] == "SUCCESS"
						@user.update(sign_in_status: 'approved')
						flash[:notice] = response[:message]
						redirect_to homes_path
					else
						flash[:notice] = response[:message]
						redirect_to two_factor_sessions_path
					end
				else
					flash[:alert] = response[:message]
					redirect_to new_session_path
				end
			else
				@user.update(sign_in_status: 'approved')
				redirect_to homes_path
			end
			
		else
			flash[:alert] = "Username/Password wrong."
			redirect_to new_session_path
		end
	end

	def logout
		current_user.update(sign_in_status: 'pending')
		session[:user_id] = nil
		flash[:notice] = "Logout successfully."
		redirect_to new_session_path
	end

	def two_factor
		
	end

	def verify_token
		token = params[:token]
		if token.present?
			# verify token
			status, response = TwoFactorAdapter::TwoFactorWrapper.new(current_user).verify_user(token)
			if status == 'success'
				current_user.update(sign_in_status: 'approved')
				flash[:notice] = response[:message]
				redirect_to homes_path
			else
				flash[:alert] = response[:message]
				redirect_to two_factor_sessions_path
			end
		else
			flash[:alert] = "Token is mandatory"
			redirect_to two_factor_sessions_path
		end
	end

	private
	def check_current_user
		unless current_user
			flash[:alert] = "Please re-login."
			redirect_to new_session_path and return
		end
	end

end
