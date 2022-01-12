class AddIndexing < ActiveRecord::Migration[4.2]
  def change
		add_index :roles, :lecture_id
		add_index :submissions, :exercise_id
		add_index :submissions, :student_id
  end
end
