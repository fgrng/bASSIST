class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
			t.integer  :lecture_id
			t.integer  :max_students

			t.timestamps
    end
  end
end
