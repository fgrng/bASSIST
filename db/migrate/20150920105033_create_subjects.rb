class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
			t.string   :name
			t.datetime :due_date
			t.integer  :lecture_id
			t.datetime :start_date

			t.timestamps
    end
  end
end
