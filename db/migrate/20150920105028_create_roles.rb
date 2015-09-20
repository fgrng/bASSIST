class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
			t.integer  :lecture_id
			t.integer  :user_id
			t.integer  :tutorial_id
			t.string   :type

			t.boolean  :validated, default: false
			t.integer  :group_number
			
			t.timestamps
    end
  end
end
