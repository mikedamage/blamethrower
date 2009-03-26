class SetupBlames < ActiveRecord::Migration
	def self.up
		create_table :blames do |t|
			t.integer :user_id
			t.integer :target_user_id
			t.string :target_user_name
			t.string	:reason
			t.timestamps
		end
	end
	
	def self.down
		drop_table :blames
	end
end