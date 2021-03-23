class CreateTwoFactorMethods < ActiveRecord::Migration[6.1]
	def change
		create_table :two_factor_methods do |t|
			t.references :user, index: true
			t.integer :name, default: 0
			t.integer :service_id
			t.integer :channel, default: 0
			t.integer :status, default: 0
			t.timestamps
		end
	end
end
