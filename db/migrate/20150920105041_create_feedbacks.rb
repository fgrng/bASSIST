class CreateFeedbacks < ActiveRecord::Migration[4.2]
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
