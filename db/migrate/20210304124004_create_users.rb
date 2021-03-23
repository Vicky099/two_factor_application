class CreateUsers < ActiveRecord::Migration[6.1]
	def change
		create_table :users do |t|
			t.string :name
			t.string :email, index: true
			t.string :country_code, default: '91'
			t.string :mob_no
			t.string :password_digest
			t.integer :sign_in_status, default: 0
			t.timestamps
		end
	end
end
