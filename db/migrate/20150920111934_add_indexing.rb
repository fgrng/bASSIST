class AddIndexing < ActiveRecord::Migration
  def change
		add_index :roles, :lecture_id
		add_index :submissions, :exercise_id
		add_index :submissions, :student_id
  end
end
