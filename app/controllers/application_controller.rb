class ApplicationController < ActionController::Base

	protect_from_forgery with: :exception

  	def current_user
      User.find_by(id: session[:user_id])
  	end
  	helper_method :current_user

  	def signed_in?
    	current_user.present? && current_user.approved?
  	end
  	helper_method :signed_in?

  	protected

  	def authenticate!
  		unless signed_in?
    		flash[:alert] = "Invalid Access. Please login first."
    		redirect_to new_session_path and return 
  		end
  	end

  	# for sign-in and signup click of user aleady login 
  	def check_redirect_if_user_login
  		if signed_in?
  			flash[:alert] = "You are already login."
  			redirect_to homes_path and return 
  		end
  	end
  	
end
