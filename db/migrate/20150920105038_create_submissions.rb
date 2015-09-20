class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
			t.integer  :student_id
			t.integer  :exercise_id

			t.text     :text, default: ""
			t.boolean  :is_visible,  default: false
			t.boolean  :external, default: false
			t.string   :comment

			t.timestamps
    end
  end
end
