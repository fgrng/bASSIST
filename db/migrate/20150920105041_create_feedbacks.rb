class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
			t.integer  :submission_id
			t.text     :text, default: ""
			t.boolean  :passed, default: false
			t.boolean  :is_visible,  default: false
			t.float    :grade

			t.timestamps
    end
  end
end
