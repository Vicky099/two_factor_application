class ChnageDataTypeOfServiceIdToTwoFactorMethod < ActiveRecord::Migration[6.1]
	def up
		change_column :two_factor_methods, :service_id, :string
	end

	def down
		change_column :two_factor_methods, :service_id, :integer, using: 'service_id::integer'
	end
end
