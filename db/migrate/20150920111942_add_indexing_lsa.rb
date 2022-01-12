class AddIndexingLsa < ActiveRecord::Migration[4.2]
  def change
    # Plagiarisms
		add_index :lsa_plagiarisms, [:lsa_run_id, :lsa_run_type]
		add_index :lsa_plagiarisms, :submission_a_id
		add_index :lsa_plagiarisms, :submission_b_id
		add_index :lsa_plagiarisms, :lsa_passage_collection_a_id
		add_index :lsa_plagiarisms, :lsa_passage_collection_b_id
		add_index :lsa_passages, :lsa_passage_collection_id
		# Sortings
		add_index :lsa_sortings, [:lsa_run_id, :lsa_run_type]
		add_index :lsa_sortings, :submission_id
		# Scorings
		add_index :lsa_scorings, [:lsa_run_id, :lsa_run_type]
		add_index :lsa_scorings, :submission_id
	end
end
