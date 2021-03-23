class AddServiceFactorIdToTwoFactorMethod < ActiveRecord::Migration[6.1]
  	def change
  		add_column :two_factor_methods, :service_factor_id, :string
  	end
end
