class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
			t.integer :subject_id
			t.string  :type
			t.text :text
			t.text :ideal_solution
			t.integer :group_number
			t.boolean :is_visible, :default => false
			t.float :min_points, :default => 0.0
			t.float :max_points, :detault => 100.0
			t.timestamps
    end
  end
end
