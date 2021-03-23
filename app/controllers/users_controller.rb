class UsersController < ApplicationController
	before_action :authenticate!, except: [:new, :register]
	before_action :check_redirect_if_user_login, only: [:new]

	def new
		# only current user not 2f approved. then reset session
		if current_user
			session[:user_id] = nil
		end
		@user = User.new
		@user.two_factor_methods.build
	end

	def register
		@user = User.new(user_params)
		if @user.save			
			flash[:notice] = "Your are registered successfully."
			redirect_to new_session_path
		else
			flash[:alert] = @user.errors.full_messages.join(", ")
			render :new
		end
		
	end

	def edit
		@two_factor_method = current_user.get_two_factor_method || current_user.two_factor_methods.build
	end

	def update 
		if current_user.update(user_params)
			flash[:notice] = "Information updated successfully."
		else
			flash[:alert] = current_user.errors.full_messages.join(", ")
		end
		redirect_to edit_user_path(current_user)
	end

	def update_two_factor
		record = current_user.two_factor_methods.find_by(name: two_factor_params['name'])
		if record.present?
			record.update(two_factor_params)
		else
			record = current_user.two_factor_methods.build(two_factor_params)
			record.save
		end

		# De-Activate other than record
		r_records = current_user.two_factor_methods.where.not(name: record.name)
		if !r_records.empty?
			record.update(status: 'active')
			r_records.update_all(status: 'inactive')
		end

		if current_user.get_two_factor_method.service_id.present?
			status = "success" #already registered
			response = {message: 'User already registered for two factor'}
		else
			status, response = TwoFactorAdapter::TwoFactorWrapper.new(current_user).register_user
		end

		if status == 'success'
			status, response = TwoFactorAdapter::TwoFactorWrapper.new(current_user).enroll_factor
			if status == "success"
				flash[:notice] = response[:message]
				redirect_to get_token_to_activate_factor_users_path(f_id: response[:id], barcode: response[:barcode])
			else
				flash[:alert] = response[:message]
				redirect_to edit_user_path(current_user)
			end
		else
			flash[:alert] = response[:message]
			redirect_to edit_user_path(current_user)
		end
	end

	def get_token_to_activate_factor
		@f_id = params[:f_id]
		@barcode = params[:barcode]
	end

	def activate_factor
		status, response = TwoFactorAdapter::TwoFactorWrapper.new(current_user).activate_factor(params[:f_id], params[:token])
		if status == 'success'
			flash[:notice] = response[:message]
			redirect_to edit_user_path(current_user)
		else
			flash[:alert] = response[:message]
			redirect_to get_token_to_activate_factor_users_path(f_id: params[:f_id], barcode: response[:barcode])
		end
	end

	def deactive_two_factor

	end

	private
	def user_params
		params.require(:user).permit(:name, :email, :country_code, :mob_no, :password, :password_confirmation, two_factor_methods_attributes: [:id, :name, :channel, :status])
	end

	def two_factor_params
		params.require(:two_factor_method).permit(:name, :channel, :status)
	end
end
