class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
			t.integer  :active_lecture_id
			t.string   :email
			t.string   :first_name
			t.string   :last_name
			t.string   :password_digest

			t.boolean  :validated,                default: false
			t.boolean  :is_admin,                 default: false
			t.boolean  :is_assistant,             default: false

			t.string   :remember_token
			t.string   :password_reset_token
			t.datetime :password_reset_sent_at
			t.string   :email_validation_token
			t.datetime :email_validation_sent_at

			t.timestamps
		end
  end
end
