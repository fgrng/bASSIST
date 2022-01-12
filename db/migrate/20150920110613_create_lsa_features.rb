class CreateLsaFeatures < ActiveRecord::Migration[4.2]
  def change
		create_table :lsa_passage_collections do |t|
			t.integer  :submission_id
			t.integer  :source_id
			t.float    :percentage
			t.integer  :passage_count
			t.timestamps
		end

		create_table :lsa_passages  do |t|
			t.integer :lsa_passage_collection_id
			t.integer :mirror_id
			t.integer :first
			t.integer :last
		end

		create_table :lsa_plagiarisms  do |t|
			t.integer :lsa_run_id
			t.string  :lsa_run_type
			t.integer :submission_a_id
			t.integer :submission_b_id
			t.integer :lsa_passage_collection_a_id
			t.integer :lsa_passage_collection_b_id
			t.float   :cosine
			t.integer :watched, default: 0
			t.timestamps
		end

		create_table :lsa_runs  do |t|
			t.integer  :exercise_id
			t.integer  :lsa_server_id
			t.integer  :user_id
			t.integer  :delayed_job_id
			t.integer  :lecture_id
			t.string   :type
			t.string   :error_message
			t.text     :ideal_solution
			t.text     :first_scored_text
			t.text     :second_scored_text
			t.float    :first_text_score
			t.float    :second_text_score
			t.datetime :schedule_time
			t.datetime :start_time
			t.datetime :stop_time
			t.timestamps
		end

		create_table :lsa_scorings  do |t|
			t.integer  :lsa_run_id
			t.integer  :submission_id
			t.string   :lsa_run_type
			t.float    :grade
			t.timestamps
		end

		create_table :lsa_servers  do |t|
			t.string   :name
			t.string   :json_url
			t.string   :rmi_url
			t.integer  :rmi_port
			t.integer  :json_port
			t.string   :json_path
			t.timestamps
		end

		create_table :lsa_sortings  do |t|
			t.integer  :lsa_run_id
			t.integer  :submission_id
			t.string   :lsa_run_type
			t.integer  :position
			t.timestamps
		end
		
    create_table :exercises_lsa_runs, id: false do |t|
			t.integer :exercise_id
			t.integer :lsa_run_id
		end

	end
end
