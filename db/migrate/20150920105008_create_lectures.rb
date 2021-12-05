class CreateLectures < ActiveRecord::Migration
  def change
    create_table :lectures do |t|
			t.string   :name
			t.datetime :year
			t.string   :term
			t.text     :description
			t.string   :teacher

			t.integer  :max_group, default: 0

			t.datetime :register_start
			t.datetime :register_stop

			t.string   :tutor_key
			t.string   :teacher_key

			t.boolean  :is_visible, default: false
			t.boolean  :closed, default: false
			t.boolean  :show_lsa_score, default: false

			# Exercise Names
			t.string   :statement_name, default: "Statement"
			t.string   :a_statement_name, default: "Statement A"
			t.string   :b_statement_name, default: "Statement B"
			t.string   :c_statement_name, default: "Statement C"
			t.string   :reflection_name, default: "Reflektion"
			t.string   :a_reflection_name, default: "Reflektion A"
			t.string   :b_reflection_name, default: "Reflektion B"
			t.string   :c_reflection_name, default: "Reflektion C"

			t.timestamps
    end
  end
end
