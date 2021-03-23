class AddBackupCodeToTwoFactorMethod < ActiveRecord::Migration[6.1]
	def change
		add_column :two_factor_methods, :backup_service_factor_id, :string
	end
end
