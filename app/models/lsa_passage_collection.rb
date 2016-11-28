class LsaPassageCollection < ApplicationRecord

	# Attributes
	#
	# t.float    "percentage"
  # t.integer  "passage_count"
  # t.integer  "submission_id"
  # t.integer  "source_id"

	# Associations

	has_one :lsa_plagiarism
	has_many :lsa_passages, dependent: :destroy

	belongs_to :submission, class_name: "Submission"
	belongs_to :source, class_name: "Submission"

end
